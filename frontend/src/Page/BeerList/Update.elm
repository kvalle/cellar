module Page.BeerList.Update exposing (update)

import Backend.Beers
import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(LoggedIn))
import Data.KeyEvent exposing (keys)
import Dom
import Http
import Data.BeerList
import Page.BeerList.Messages exposing (Msg(..))
import Page.BeerList.Model exposing (Model)
import Page.BeerList.Model.Filters as Filter
import Page.BeerList.Model.State as State exposing (Network(..))
import Task


update : Msg -> AppState -> Model -> ( Model, Cmd Msg )
update msg appState model =
    case msg of
        SetTableState state ->
            ( { model | tableState = state }, Cmd.none )

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

        DeleteBeer beer ->
            case appState.auth of
                LoggedIn userData ->
                    let
                        newBeers =
                            Data.BeerList.delete beer model.beers
                    in
                        ( { model
                            | beers = newBeers
                            , state = model.state |> State.withNetwork Saving
                            , filters = model.filters |> Filter.setContext newBeers
                          }
                        , Http.send SavedBeerList <|
                            Backend.Beers.save appState.environment userData newBeers
                        )

                _ ->
                    -- FIXME : not really a possible state
                    ( { model | state = model.state |> State.withError "You need to log in" }, Cmd.none )

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
                        -- FIXME show 'add beer' form
                        ( model, Cmd.none )
                    else if key == keys.f && State.isClearOfModals model.state then
                        update ShowFilters appState model
                    else if key == keys.r && model.state.changes == State.Changed && State.isClearOfModals model.state then
                        -- FIXME update LoadBeers appState model
                        ( model, Cmd.none )
                    else if key == keys.s && model.state.changes == State.Changed && State.isClearOfModals model.state then
                        -- FIXME update SaveBeers appState model
                        ( model, Cmd.none )
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
