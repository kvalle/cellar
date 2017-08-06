module Main exposing (..)

import Page.BeerList.Model.Environment
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
    , environment : Page.BeerList.Model.Environment.Environment
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
        , environment = Page.BeerList.Model.Environment.fromLocation flags.location
        }


type alias Flags =
    { location : String }



-- init : Flags -> ( Model, Cmd Msg )
-- init flags =
--     let
--         environment =
--             Model.Environment.fromLocation flags.location
--     in
--         ( Model.init environment, Cmd.none )


type Msg
    = SetRoute (Maybe Route)
    | BeerListLoaded (Result PageLoadError Page.BeerList.Model.Model)
    | BeerListMsg Page.BeerList.Messages.Msg


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
                transition BeerListLoaded (Page.BeerList.Model.init model.environment)


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



-- main : Program Flags Model Msg
-- main =
--     Html.programWithFlags
--         { init = init
--         , view = View.view
--         , update = Update.update
--         , subscriptions = Subscriptions.subscriptions
--         }
--
-- type alias Flags =
--     { location : String }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map BeerListMsg Page.BeerList.Subscriptions.subscriptions
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
            viewPage False page

        TransitioningFrom page ->
            viewPage True page


viewPage : Bool -> Page -> Html Msg
viewPage isLoading page =
    case page of
        NotFound ->
            Page.NotFound.view

        Blank ->
            Html.text ""

        Errored subModel ->
            Errored.view subModel

        About ->
            Page.About.view

        BeerList subModel ->
            Page.BeerList.View.view subModel
                |> Html.map BeerListMsg
