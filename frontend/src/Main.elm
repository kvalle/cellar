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
    setRoute (Route.fromLocation location)
        { pageState = Loaded Blank
        , appState =
            { environment = Data.Environment.fromLocation flags.location
            , auth = Data.Auth.LoggedOut
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


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task =
            { model | pageState = TransitioningFrom (getPage model.pageState) }
                => Task.attempt toMsg task
    in
        case maybeRoute of
            Nothing ->
                { model | pageState = Loaded NotFound } => Cmd.none

            Just (Route.About) ->
                { model | pageState = Loaded About } => Cmd.none

            Just (Route.BeerList) ->
                transition BeerListLoaded (Page.BeerList.Model.init model.appState)


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
    updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    let
        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
                ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )

        errored =
            pageErrored model
    in
        case ( msg, page ) of
            ( SetRoute route, _ ) ->
                setRoute route model

            ( Login, _ ) ->
                model => Ports.login ()

            ( Logout, _ ) ->
                model => Ports.logout ()

            ( LoginResult userData, _ ) ->
                { model | appState = model.appState |> Data.AppState.setAuth (Data.Auth.LoggedIn userData) } => Cmd.none

            ( LogoutResult _, _ ) ->
                { model | appState = model.appState |> Data.AppState.setAuth Data.Auth.LoggedOut } => Cmd.none

            ( BeerListLoaded (Ok subModel), _ ) ->
                { model | pageState = Loaded (BeerList subModel) } => Cmd.none

            ( BeerListLoaded (Err error), _ ) ->
                { model | pageState = Loaded (Errored error) } => Cmd.none

            ( BeerListMsg subMsg, BeerList subModel ) ->
                toPage BeerList BeerListMsg Page.BeerList.Update.update subMsg subModel

            ( _, NotFound ) ->
                -- Disregard incoming messages when we're on the
                -- NotFound page.
                model => Cmd.none

            ( _, _ ) ->
                -- Disregard incoming messages that arrived for the wrong page
                model => Cmd.none


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
                    |> frame

            Blank ->
                Html.text ""

            Errored subModel ->
                Errored.view subModel
                    |> frame

            About ->
                Page.About.view
                    |> frame

            BeerList subModel ->
                Page.BeerList.View.view subModel
                    |> Html.map BeerListMsg
                    |> frame
