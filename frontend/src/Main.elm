module Main exposing (..)

import Ports
import Data.Environment
import Html exposing (Html)
import Route exposing (Route)
import Page.Errored as Errored exposing (PageLoadError)
import Page.About
import Page.NotFound
import Page.BeerList.Model
import Page.BeerList.Update
import Page.BeerList.Messages
import Page.BeerList.View
import Page.BeerList.Subscriptions
import Util exposing ((=>))
import Task
import Navigation exposing (Location)
import Data.Auth
import Data.AppState exposing (AppState)
import Views.Page


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | About
    | BeerList Page.BeerList.Model.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { pageState : PageState
    , appState : AppState
    }



-- MAIN --


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        route =
            (Route.fromLocation location)
    in
        setRoute route
            { pageState = Loaded Blank
            , appState =
                { environment = Data.Environment.fromLocation flags.location
                , auth = Data.Auth.Checking route
                }
            }


type alias Flags =
    { location : String }


type Msg
    = SetRoute (Maybe Route)
    | BeerListLoaded (Result PageLoadError Page.BeerList.Model.Model)
    | BeerListMsg Page.BeerList.Messages.Msg
    | Login
    | Logout
    | LoginResult Data.Auth.UserData
    | LogoutResult ()


pageErrored : Model -> String -> ( Model, Cmd msg )
pageErrored model errorMessage =
    let
        error =
            Errored.pageLoadError errorMessage
    in
        { model | pageState = Loaded (Errored error) } => Cmd.none


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.loginResult LoginResult
        , Ports.logoutResult LogoutResult
        , Sub.map BeerListMsg Page.BeerList.Subscriptions.subscriptions
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "Update got" msg

        page =
            getPage model.pageState

        toPage toModel toMsg subUpdate subMsg appState subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg appState subModel
            in
                ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )
    in
        case ( msg, page ) of
            ( SetRoute route, _ ) ->
                setRoute route model

            ( Login, _ ) ->
                model => Ports.login ()

            ( Logout, _ ) ->
                model => Ports.logout ()

            ( LoginResult userData, _ ) ->
                let
                    newModel =
                        { model | appState = model.appState |> Data.AppState.setAuth (Data.Auth.LoggedIn userData) }
                in
                    case model.appState.auth of
                        Data.Auth.LoggedOut route ->
                            setRoute route newModel

                        Data.Auth.Checking route ->
                            setRoute route newModel

                        Data.Auth.LoggedIn _ ->
                            newModel => Cmd.none

            ( LogoutResult _, _ ) ->
                { model | appState = model.appState |> Data.AppState.setAuth (Data.Auth.LoggedOut (Just Route.BeerList)) } => Cmd.none

            ( BeerListLoaded (Ok subModel), _ ) ->
                { model | pageState = Loaded (BeerList subModel) } => Cmd.none

            ( BeerListLoaded (Err error), _ ) ->
                { model | pageState = Loaded (Errored error) } => Cmd.none

            ( BeerListMsg subMsg, BeerList subModel ) ->
                toPage BeerList BeerListMsg Page.BeerList.Update.update subMsg model.appState subModel

            ( msg, _ ) ->
                let
                    _ =
                        Debug.log ("Ignored msg " ++ (toString msg) ++ " since it's irrelevant for page") page
                in
                    -- Disregard incoming messages that arrived for the wrong page
                    model => Cmd.none


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        _ =
            Debug.log "Setting route" maybeRoute

        transition toMsg task =
            { model | pageState = TransitioningFrom (getPage model.pageState) }
                => Task.attempt toMsg task

        dispatch maybeRoute model =
            case maybeRoute of
                Nothing ->
                    { model | pageState = Loaded NotFound } => Cmd.none

                Just (Route.About) ->
                    { model | pageState = Loaded About } => Cmd.none

                Just (Route.BeerList) ->
                    transition BeerListLoaded (Page.BeerList.Model.init model.appState)

                Just (Route.AuthRedirect _) ->
                    model => Cmd.none

        requiresLogin maybeRoute =
            case maybeRoute of
                Just (Route.BeerList) ->
                    True

                _ ->
                    False
    in
        case ( requiresLogin maybeRoute, model.appState.auth ) of
            ( True, Data.Auth.Checking _ ) ->
                { model | appState = model.appState |> Data.AppState.setAuth (Data.Auth.Checking maybeRoute) } => Cmd.none

            ( True, Data.Auth.LoggedOut _ ) ->
                { model | appState = model.appState |> Data.AppState.setAuth (Data.Auth.LoggedOut maybeRoute) } => Cmd.none

            _ ->
                dispatch maybeRoute model


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage model.appState False page

        TransitioningFrom page ->
            viewPage model.appState True page


viewPage : AppState -> Bool -> Page -> Html Msg
viewPage appState isLoading page =
    let
        frame =
            Views.Page.frame Login Logout isLoading appState
    in
        case page of
            NotFound ->
                Page.NotFound.view
                    |> frame Views.Page.Other

            Blank ->
                Html.text ""
                    |> frame Views.Page.Other

            Errored subModel ->
                Errored.view subModel
                    |> frame Views.Page.Other

            About ->
                Page.About.view
                    |> frame Views.Page.About

            BeerList subModel ->
                Page.BeerList.View.view subModel
                    |> Html.map BeerListMsg
                    |> frame Views.Page.BeerList
