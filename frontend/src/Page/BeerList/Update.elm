module Page.BeerList.Update exposing (update)

import Page.BeerList.Messages exposing (Msg(..))
import Page.BeerList.Messages.BeerForm exposing (SuggestionMsg(..))
import Ports
import Page.BeerList.Model exposing (Model)
import Page.BeerList.Model.State as State exposing (Network(..))
import Page.BeerList.Model.BeerForm as BeerForm
import Data.Beer as Beer
import Page.BeerList.Model.Filters as Filter
import Page.BeerList.Model.BeerList
import Dom
import Task
import Page.BeerList.Model.KeyEvent exposing (keys)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( model
            , Ports.login ()
            )

        LoginResult userData ->
            -- ( { model | auth = LoggedIn userData }
            -- , Page.BeerList.Commands.fetchBeers model.env <| LoggedIn userData
            -- )
            ( model, Cmd.none )

        Logout ->
            ( model
            , Ports.logout ()
            )

        LogoutResult _ ->
            -- ( { model | auth = LoggedOut, beers = [] }, Cmd.none )
            ( model, Cmd.none )

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
              -- FIXME
              --, Page.BeerList.Commands.saveBeers model.env model.auth model.beers
            , Cmd.none
            )

        LoadBeers ->
            ( { model | state = State.withNetwork Loading model.state }
              -- FIXME
              --, Page.BeerList.Commands.fetchBeers model.env model.auth
            , Cmd.none
            )

        ShowJsonModal ->
            ( { model | state = model.state |> State.withJsonModal State.Visible }, Cmd.none )

        HideJsonModal ->
            ( { model | state = model.state |> State.withJsonModal State.Hidden }, Cmd.none )

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

        ShowForm beer ->
            ( { model
                | beerForm = BeerForm.from beer model.beers
                , state = model.state |> State.withBeerForm State.Visible
              }
            , Dom.focus "brewery-input" |> Task.attempt FocusResult
            )

        HideForm ->
            ( { model
                | state = model.state |> State.withBeerForm State.Hidden
              }
            , Cmd.none
            )

        UpdateFormField field input ->
            ( { model
                | beerForm =
                    model.beerForm
                        |> BeerForm.updateField field input
                        |> BeerForm.updateSuggestions field Refresh
              }
            , Cmd.none
            )

        UpdateFormSuggestions field msg ->
            ( { model
                | beerForm = model.beerForm |> BeerForm.updateSuggestions field msg
              }
            , Cmd.none
            )

        SubmitForm ->
            let
                newBeers =
                    Page.BeerList.Model.BeerList.addOrUpdate (BeerForm.toBeer model.beerForm) model.beers
            in
                ( { model
                    | beers = newBeers
                    , beerForm = BeerForm.empty model.beers
                    , state = model.state |> State.withChanges |> State.withBeerForm State.Hidden
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
                        update ClearModals model
                    else if key == keys.a && State.isClearOfModals model.state then
                        update (ShowForm Beer.empty) model
                    else if key == keys.f && State.isClearOfModals model.state then
                        update ShowFilters model
                    else if key == keys.j && State.isClearOfModals model.state then
                        update ShowJsonModal model
                    else if key == keys.r && model.state.changes == State.Changed && State.isClearOfModals model.state then
                        update LoadBeers model
                    else if key == keys.s && model.state.changes == State.Changed && State.isClearOfModals model.state then
                        update SaveBeers model
                    else if key == keys.c && model.filters.active && State.isClearOfModals model.state then
                        update ClearFilters model
                    else if key == keys.questionMark && State.isClearOfModals model.state then
                        update ShowHelp model
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

        HideHelp ->
            ( { model | state = model.state |> State.withHelpDialog State.Hidden }, Cmd.none )

        ShowHelp ->
            ( { model | state = model.state |> State.withHelpDialog State.Visible }, Cmd.none )

        Noop ->
            ( model, Cmd.none )