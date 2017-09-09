module Main exposing (..)

import Backend.Auth
import Data.AppState exposing (AppState)
import Data.Auth
import Html exposing (Html)
import Json.Decode as Decode exposing (Value, field, null)
import Navigation exposing (Location)
import Page.BeerList.Messages
import Page.BeerList.Model
import Page.BeerList.Subscriptions
import Page.BeerList.Update
import Page.BeerList.View
import Page.BeerForm.Messages
import Page.BeerForm.Model
import Page.BeerForm.Update
import Page.BeerForm.View
import Page.Errored
import Page.Home
import Page.Help
import Page.Json
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
    | Help
    | Json Page.Json.Model
    | BeerList Page.BeerList.Model.Model
    | BeerForm Page.BeerForm.Model.Model
    | NotFound
    | Errored Page.Errored.Model


type PageState
    = Loaded Page Data.Page.ActivePage
    | TransitioningFrom Page Data.Page.ActivePage


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
        { pageState = Loaded Blank Data.Page.Other
        , appState = Data.AppState.decodeFromJson flags
        }


type Msg
    = SetRoute Route
    | BeerListLoaded (Result Page.Errored.Model Page.BeerList.Model.Model)
    | BeerFormLoaded (Result Page.Errored.Model Page.BeerForm.Model.Model)
    | JsonLoaded (Result Page.Errored.Model Page.Json.Model)
    | BeerListMsg Page.BeerList.Messages.Msg
    | BeerFormMsg Page.BeerForm.Messages.Msg
    | Login
    | LoginResult (Result String ( Data.Auth.Session, Route.Route ))
    | Logout


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page _ ->
            page

        TransitioningFrom page _ ->
            page


getActivePage : PageState -> Data.Page.ActivePage
getActivePage pageState =
    case pageState of
        Loaded _ activePage ->
            activePage

        TransitioningFrom _ activePage ->
            activePage


subscriptions : Model -> Sub Msg
subscriptions model =
    case getPage model.pageState of
        BeerList _ ->
            Sub.map BeerListMsg Page.BeerList.Subscriptions.subscriptions

        _ ->
            Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "Update msg:" msg

        delegateToPage toPage activePage toMsg subUpdate subMsg appState subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg appState subModel
            in
                ( { model | pageState = Loaded (toPage newModel) activePage }, Cmd.map toMsg newCmd )
    in
        case msg of
            SetRoute route ->
                setRoute route model

            Login ->
                let
                    redirectString =
                        (Route.toName << Route.fromActivePage << getActivePage) model.pageState

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

            JsonLoaded (Ok subModel) ->
                { model | pageState = Loaded (Json subModel) Data.Page.Json } => Cmd.none

            JsonLoaded (Err error) ->
                { model | pageState = Loaded (Errored error) Data.Page.Json } => Cmd.none

            BeerListLoaded (Ok subModel) ->
                { model | pageState = Loaded (BeerList subModel) Data.Page.BeerList } => Cmd.none

            BeerListLoaded (Err error) ->
                { model | pageState = Loaded (Errored error) Data.Page.BeerList } => Cmd.none

            BeerFormLoaded (Ok subModel) ->
                { model | pageState = Loaded (BeerForm subModel) (getActivePage model.pageState) } => Cmd.none

            BeerFormLoaded (Err error) ->
                { model | pageState = Loaded (Errored error) (getActivePage model.pageState) } => Cmd.none

            BeerListMsg subMsg ->
                case getPage model.pageState of
                    BeerList subModel ->
                        delegateToPage BeerList Data.Page.BeerList BeerListMsg Page.BeerList.Update.update subMsg model.appState subModel

                    _ ->
                        -- Disregard BeerListMsg for other pages
                        model => Cmd.none

            BeerFormMsg subMsg ->
                case getPage model.pageState of
                    BeerForm subModel ->
                        delegateToPage BeerForm (getActivePage model.pageState) BeerFormMsg Page.BeerForm.Update.update subMsg model.appState subModel

                    _ ->
                        -- Disregard BeerListMsg for other pages
                        model => Cmd.none


setRoute : Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task activePage =
            { model | pageState = TransitioningFrom (getPage model.pageState) activePage }
                => Task.attempt toMsg task

        pageErrored : Data.Page.ActivePage -> String -> Model -> Model
        pageErrored activePage errorMessage model =
            { model | pageState = Loaded (Errored errorMessage) activePage }
    in
        case ( maybeRoute, model.appState.auth ) of
            ( Route.BeerList, Data.Auth.LoggedOut ) ->
                pageErrored Data.Page.BeerList "You need to log in to see this page." model
                    => Cmd.none

            ( Route.AddBeer, Data.Auth.LoggedOut ) ->
                pageErrored Data.Page.AddBeer "You need to log in to see this page." model
                    => Cmd.none

            ( Route.Unknown, _ ) ->
                { model | pageState = Loaded NotFound Data.Page.Other } => Cmd.none

            ( Route.Home, _ ) ->
                { model | pageState = Loaded Home Data.Page.Home } => Cmd.none

            ( Route.BeerList, _ ) ->
                transition BeerListLoaded (Page.BeerList.Model.init model.appState) Data.Page.BeerList

            ( Route.AddBeer, _ ) ->
                transition BeerFormLoaded (Page.BeerForm.Model.initEmpty model.appState) Data.Page.AddBeer

            ( Route.EditBeer id, _ ) ->
                transition BeerFormLoaded (Page.BeerForm.Model.initWith id model.appState) (Data.Page.EditBeer id)

            ( Route.AccessTokenRoute callBackInfo, _ ) ->
                let
                    redirect =
                        Route.fromName callBackInfo.state
                in
                    model => Task.attempt LoginResult (Backend.Auth.login callBackInfo.idToken redirect)

            ( Route.UnauthorizedRoute x, _ ) ->
                model |> pageErrored Data.Page.Other "Login failed" => Cmd.none

            ( Route.Json, _ ) ->
                transition JsonLoaded (Page.Json.init model.appState) Data.Page.Json

            ( Route.Help, _ ) ->
                { model | pageState = Loaded Help Data.Page.Help } => Cmd.none


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page activePage ->
            viewPage model.appState False page activePage

        TransitioningFrom page activePage ->
            viewPage model.appState True page activePage


viewPage : AppState -> Bool -> Page -> Data.Page.ActivePage -> Html Msg
viewPage appState isLoading page activePage =
    let
        frame =
            Views.Page.frame Login Logout isLoading appState activePage
    in
        case page of
            NotFound ->
                Page.NotFound.view |> frame

            Json subModel ->
                Page.Json.view subModel |> frame

            Blank ->
                Html.text "" |> frame

            Errored error ->
                Page.Errored.view error |> frame

            Home ->
                Page.Home.view appState |> frame

            Help ->
                Page.Help.view |> frame

            BeerList subModel ->
                Page.BeerList.View.view subModel
                    |> Html.map BeerListMsg
                    |> frame

            BeerForm subModel ->
                Page.BeerForm.View.view subModel
                    |> Html.map BeerFormMsg
                    |> frame
