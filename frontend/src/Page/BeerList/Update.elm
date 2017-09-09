module Page.BeerList.Update exposing (update)

import Backend.Beers
import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(LoggedIn))
import Data.KeyEvent exposing (keys)
import Dom
import Http
import Page.BeerList.Messages exposing (Msg(..))
import Page.BeerList.Model exposing (Model)
import Page.BeerList.Model.BeerList
import Page.BeerList.Model.Filters as Filter
import Page.BeerList.Model.State as State exposing (Network(..))
import Task


update : Msg -> AppState -> Model -> ( Model, Cmd Msg )
update msg appState model =
    case msg of
        SetTableState state ->
            ( { model | tableState = state }, Cmd.none )

        LoadedBeerList (Err err) ->
            ( { model
                | state =
                    model.state
                        |> State.withError ("Failed to load beer list :(" ++ (toString err))
                        |> State.withNetwork Idle
              }
            , Cmd.none
            )

        LoadedBeerList (Ok beers) ->
            ( { model
                | beers = beers
                , filters = model.filters |> Filter.setContext beers
                , state =
                    model.state
                        |> State.withNetwork Idle
                        |> State.withNoChanges
              }
            , Cmd.none
            )

        SavedBeerList (Ok _) ->
            ( { model
                | state =
                    model.state
                        |> State.withNetwork Idle
                        |> State.withNoChanges
              }
            , Cmd.none
            )

        SavedBeerList (Err _) ->
            ( { model
                | state =
                    model.state
                        |> State.withError "Unable to store beer list"
                        |> State.withNetwork Idle
              }
            , Cmd.none
            )

        SaveBeers ->
            ( { model | state = State.withNetwork Saving model.state }
            , case appState.auth of
                LoggedIn userData ->
                    Http.send SavedBeerList <|
                        Backend.Beers.save appState.environment userData model.beers

                _ ->
                    Cmd.none
            )

        LoadBeers ->
            ( { model | state = State.withNetwork Loading model.state }
            , case appState.auth of
                LoggedIn userData ->
                    Http.send LoadedBeerList <|
                        Backend.Beers.get appState.environment userData

                _ ->
                    Cmd.none
            )

        ClearFilters ->
            ( { model
                | filters = Filter.empty model.beers
                , state = model.state |> State.withFilters State.Hidden
              }
            , Cmd.none
            )

        UpdateFilters value ->
            ( { model | filters = model.filters |> Filter.setValue value }, Cmd.none )

        ShowFilters ->
            ( { model | state = model.state |> State.withFilters State.Visible }
            , Dom.focus "text-filter-input" |> Task.attempt FocusResult
            )

        HideFilters ->
            ( { model | state = model.state |> State.withFilters State.Hidden }, Cmd.none )

        DecrementBeer beer ->
            let
                newBeers =
                    Page.BeerList.Model.BeerList.decrement beer model.beers
            in
                ( { model
                    | beers = newBeers
                    , state = model.state |> State.withChanges
                    , filters = model.filters |> Filter.setContext newBeers
                  }
                , Cmd.none
                )

        IncrementBeer beer ->
            let
                newBeers =
                    Page.BeerList.Model.BeerList.increment beer model.beers
            in
                ( { model
                    | beers = newBeers
                    , state = model.state |> State.withChanges
                    , filters = model.filters |> Filter.setContext newBeers
                  }
                , Cmd.none
                )

        DeleteBeer beer ->
            let
                newBeers =
                    Page.BeerList.Model.BeerList.delete beer model.beers
            in
                ( { model
                    | beers = newBeers
                    , state = model.state |> State.withChanges
                    , filters = model.filters |> Filter.setContext newBeers
                  }
                , Cmd.none
                )

        ClearModals ->
            ( { model | state = model.state |> State.clearModals }, Cmd.none )

        KeyPressed keyResult ->
            case keyResult of
                Err _ ->
                    ( model, Cmd.none )

                Ok key ->
                    if key == keys.escape then
                        update ClearModals appState model
                    else if key == keys.a && State.isClearOfModals model.state then
                        -- TODO: show 'add beer' form
                        ( model, Cmd.none )
                    else if key == keys.f && State.isClearOfModals model.state then
                        update ShowFilters appState model
                    else if key == keys.r && model.state.changes == State.Changed && State.isClearOfModals model.state then
                        update LoadBeers appState model
                    else if key == keys.s && model.state.changes == State.Changed && State.isClearOfModals model.state then
                        update SaveBeers appState model
                    else if key == keys.c && model.filters.active && State.isClearOfModals model.state then
                        update ClearFilters appState model
                    else
                        ( model, Cmd.none )

        FocusResult (Ok _) ->
            ( model, Cmd.none )

        FocusResult (Err err) ->
            let
                _ =
                    Debug.log "Unable to focus: " err
            in
                ( model, Cmd.none )

        Noop ->
            ( model, Cmd.none )
