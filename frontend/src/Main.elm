module Main exposing (..)

import Page.BeerList.Model.Environment
import Html exposing (Html)
import Route exposing (Route)
import Page.Errored as Errored exposing (PageLoadError)
import Page.Dummy1
import Page.Dummy2
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
    = NotFound
    | Errored PageLoadError
    | Dummy1 String
    | Dummy2 String
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
        { pageState = Loaded (Dummy1 "foobar")
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
    | Dummy1Loaded (Result PageLoadError Page.Dummy1.Model)
    | Dummy2Loaded (Result PageLoadError Page.Dummy2.Model)
    | BeerListLoaded (Result PageLoadError Page.BeerList.Model.Model)
    | Dummy1Msg Page.Dummy1.Msg
    | Dummy2Msg Page.Dummy2.Msg
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

            Just (Route.Dummy1) ->
                transition Dummy1Loaded (Page.Dummy1.init)

            Just (Route.Dummy2) ->
                transition Dummy2Loaded (Page.Dummy2.init)

            Just (Route.BeerList) ->
                -- FIXME: hard coded Dev should be picked from flag
                transition BeerListLoaded (Page.BeerList.Model.init Page.BeerList.Model.Environment.Dev)


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

            ( Dummy1Loaded (Ok subModel), _ ) ->
                { model | pageState = Loaded (Dummy1 subModel) } => Cmd.none

            ( Dummy1Loaded (Err error), _ ) ->
                { model | pageState = Loaded (Errored error) } => Cmd.none

            ( Dummy2Loaded (Ok subModel), _ ) ->
                { model | pageState = Loaded (Dummy2 subModel) } => Cmd.none

            ( Dummy2Loaded (Err error), _ ) ->
                { model | pageState = Loaded (Errored error) } => Cmd.none

            ( BeerListLoaded (Ok subModel), _ ) ->
                { model | pageState = Loaded (BeerList subModel) } => Cmd.none

            ( BeerListLoaded (Err error), _ ) ->
                { model | pageState = Loaded (Errored error) } => Cmd.none

            ( Dummy1Msg subMsg, Dummy1 subModel ) ->
                toPage Dummy1 Dummy1Msg Page.Dummy1.update subMsg subModel

            ( Dummy2Msg subMsg, Dummy2 subModel ) ->
                toPage Dummy2 Dummy2Msg Page.Dummy2.update subMsg subModel

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

        Errored subModel ->
            Errored.view subModel

        Dummy1 subModel ->
            Page.Dummy1.view subModel
                |> Html.map Dummy1Msg

        Dummy2 subModel ->
            Page.Dummy2.view subModel
                |> Html.map Dummy2Msg

        BeerList subModel ->
            Page.BeerList.View.view subModel
                |> Html.map BeerListMsg
