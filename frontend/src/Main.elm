module Main exposing (..)

import Backend.Auth
import Data.AppState exposing (AppState)
import Data.Auth
import Html exposing (Html)
import Json.Decode as Decode exposing (Value, field, null)
import Navigation exposing (Location)
import Page.About
import Page.BeerList.Messages
import Page.BeerList.Model
import Page.BeerList.Subscriptions
import Page.BeerList.Update
import Page.BeerList.View
import Page.Errored exposing (PageLoadError)
import Page.Home
import Page.NotFound
import Ports
import Route exposing (Route)
import Task
import Util exposing ((=>))
import Views.Page
import Data.Page


type Page
    = Blank
    | Home
    | About
    | BeerList Page.BeerList.Model.Model
    | NotFound
    | Errored Page.Errored.PageLoadError


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { pageState : PageState
    , appState : AppState
    }



-- MAIN --


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Value -> Location -> ( Model, Cmd Msg )
init flags location =
    setRoute (Route.fromLocation location)
        { pageState = Loaded Blank
        , appState = Data.AppState.decodeFromJson flags
        }


type Msg
    = SetRoute Route
    | BeerListLoaded (Result PageLoadError Page.BeerList.Model.Model)
    | BeerListMsg Page.BeerList.Messages.Msg
    | Login
    | LoginResult (Result String ( Data.Auth.Session, Route.Route ))
    | Logout


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
        [ Sub.map BeerListMsg Page.BeerList.Subscriptions.subscriptions
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "Update msg:" msg

        delegateToPage toModel toMsg subUpdate subMsg appState subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg appState subModel
            in
                ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )
    in
        case msg of
            SetRoute route ->
                setRoute route model

            Login ->
                let
                    fromPage : Page -> Route.Route
                    fromPage page =
                        case page of
                            BeerList _ ->
                                Route.BeerList

                            About ->
                                Route.About

                            Blank ->
                                Route.Unknown

                            Home ->
                                Route.Home

                            NotFound ->
                                Route.Unknown

                            Errored _ ->
                                Route.Unknown

                    redirectString =
                        (Route.toName << fromPage << getPage) model.pageState

                    _ =
                        Debug.log "Redirect after login back to: " redirectString
                in
                    model => Ports.showAuth0Lock redirectString

            LoginResult (Ok ( session, redirect )) ->
                { model | appState = model.appState |> Data.AppState.setAuth (Data.Auth.LoggedIn session) }
                    => Cmd.batch
                        [ Ports.setSessionStorage session
                        , Route.modifyUrl redirect
                        ]

            LoginResult (Err error) ->
                { model | appState = model.appState |> Data.AppState.setAuth Data.Auth.LoggedOut }
                    => Ports.clearSessionStorage ()

            Logout ->
                { model | appState = model.appState |> Data.AppState.setAuth Data.Auth.LoggedOut }
                    => Cmd.batch
                        [ Ports.clearSessionStorage ()
                        , Route.modifyUrl Route.Home
                        ]

            BeerListLoaded (Ok subModel) ->
                { model | pageState = Loaded (BeerList subModel) } => Cmd.none

            BeerListLoaded (Err error) ->
                { model | pageState = Loaded (Errored error) } => Cmd.none

            BeerListMsg subMsg ->
                case getPage model.pageState of
                    BeerList subModel ->
                        delegateToPage BeerList BeerListMsg Page.BeerList.Update.update subMsg model.appState subModel

                    _ ->
                        -- Disregard BeerListMsg for other pages
                        model => Cmd.none


setRoute : Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task =
            { model | pageState = TransitioningFrom (getPage model.pageState) }
                => Task.attempt toMsg task

        pageErrored : Data.Page.ActivePage -> String -> Model -> Model
        pageErrored activePage errorMessage model =
            let
                error =
                    Page.Errored.pageLoadError activePage errorMessage
            in
                { model | pageState = Loaded (Errored error) }
    in
        case ( maybeRoute, model.appState.auth ) of
            ( Route.BeerList, Data.Auth.LoggedOut ) ->
                pageErrored Data.Page.BeerList "You need to log in" model
                    => Cmd.none

            ( Route.Unknown, _ ) ->
                { model | pageState = Loaded NotFound } => Cmd.none

            ( Route.About, _ ) ->
                { model | pageState = Loaded About } => Cmd.none

            ( Route.Home, _ ) ->
                { model | pageState = Loaded Home } => Cmd.none

            ( Route.BeerList, _ ) ->
                transition BeerListLoaded (Page.BeerList.Model.init model.appState)

            ( Route.AccessTokenRoute callBackInfo, _ ) ->
                let
                    redirect =
                        Route.fromName callBackInfo.state
                in
                    model => Task.attempt LoginResult (Backend.Auth.login callBackInfo.idToken redirect)

            ( Route.UnauthorizedRoute x, _ ) ->
                model |> pageErrored Data.Page.Other "Login failed" => Cmd.none


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
                    |> frame Data.Page.Other

            Blank ->
                Html.text ""
                    |> frame Data.Page.Other

            Errored error ->
                Page.Errored.view error
                    |> frame (Page.Errored.getActivePage error)

            Home ->
                Page.Home.view
                    |> frame Data.Page.Home

            About ->
                Page.About.view
                    |> frame Data.Page.About

            BeerList subModel ->
                Page.BeerList.View.view subModel
                    |> Html.map BeerListMsg
                    |> frame Data.Page.BeerList
