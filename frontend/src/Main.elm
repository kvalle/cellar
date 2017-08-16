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


type Page
    = Blank
    | Home
    | About
    | BeerList Page.BeerList.Model.Model
    | NotFound
    | Errored PageLoadError


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
    let
        route =
            Route.fromLocation location
    in
        setRoute route
            { pageState = Loaded Blank
            , appState = Data.AppState.decodeFromJson route flags
            }


type Msg
    = SetRoute Route
    | BeerListLoaded (Result PageLoadError Page.BeerList.Model.Model)
    | BeerListMsg Page.BeerList.Messages.Msg
    | Login
    | LoginResult (Result String Data.Auth.Session)
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
                model => Ports.showAuth0Lock ()

            LoginResult (Ok session) ->
                { model | appState = model.appState |> Data.AppState.setAuth (Data.Auth.LoggedIn session) }
                    => Ports.setSessionStorage session

            LoginResult (Err error) ->
                { model | appState = model.appState |> Data.AppState.setAuth (Data.Auth.LoggedOut Data.Auth.NoRedirect) }
                    => Ports.clearSessionStorage ()

            Logout ->
                { model | appState = model.appState |> Data.AppState.setAuth (Data.Auth.LoggedOut Data.Auth.NoRedirect) }
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

        pageErrored : Views.Page.ActivePage -> String -> Model -> Model
        pageErrored activePage errorMessage model =
            let
                error =
                    Page.Errored.pageLoadError activePage errorMessage
            in
                { model | pageState = Loaded (Errored error) }

        setRedirectRoute : Data.Auth.AuthRedirect -> (Data.Auth.AuthRedirect -> Data.Auth.AuthStatus) -> Model -> Model
        setRedirectRoute redirect authStatus model =
            { model | appState = model.appState |> Data.AppState.setAuth (authStatus redirect) }
    in
        case ( maybeRoute, model.appState.auth ) of
            ( Route.BeerList, Data.Auth.LoggedOut _ ) ->
                model
                    |> setRedirectRoute (Data.Auth.Redirect Route.BeerList) Data.Auth.LoggedOut
                    |> pageErrored Views.Page.BeerList "You need to log in"
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
                model => Task.attempt LoginResult (Backend.Auth.login callBackInfo.idToken)

            ( Route.UnauthorizedRoute x, _ ) ->
                model |> pageErrored Views.Page.Other "Login failed" => Cmd.none


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

            Errored error ->
                Page.Errored.view error
                    |> frame (Page.Errored.getActivePage error)

            Home ->
                Page.Home.view
                    |> frame Views.Page.Home

            About ->
                Page.About.view
                    |> frame Views.Page.About

            BeerList subModel ->
                Page.BeerList.View.view subModel
                    |> Html.map BeerListMsg
                    |> frame Views.Page.BeerList
