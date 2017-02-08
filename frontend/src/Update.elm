module Update exposing (update)

import Messages exposing (Msg(..))
import Messages.BeerForm exposing (SuggestionMsg(..))
import Commands
import Ports
import Model exposing (Model)
import Model.State as State exposing (Network(..))
import Model.Auth exposing (AuthStatus(..))
import Model.BeerForm as BeerForm
import Model.Filters as Filter
import Model.BeerList


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( model
            , Ports.login ()
            )

        LoginResult userData ->
            ( { model | auth = LoggedIn userData }
            , Commands.fetchBeers model.env <| LoggedIn userData
            )

        Logout ->
            ( model
            , Ports.logout ()
            )

        LogoutResult _ ->
            ( { model | auth = LoggedOut, beers = [] }, Cmd.none )

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
            , Commands.saveBeers model.env model.auth model.beers
            )

        LoadBeers ->
            ( { model | state = State.withNetwork Loading model.state }
            , Commands.fetchBeers model.env model.auth
            )

        ShowJsonModal ->
            ( { model | state = model.state |> State.withJsonModal State.Visible }, Cmd.none )

        HideJsonModal ->
            ( { model | state = model.state |> State.withJsonModal State.Hidden }, Cmd.none )

        ClearFilters ->
            ( { model | filters = Filter.empty model.beers }, Cmd.none )

        UpdateFilters value ->
            ( { model | filters = model.filters |> Filter.setValue value }, Cmd.none )

        ShowFilters ->
            ( { model | state = model.state |> State.withFilters State.Visible }, Cmd.none )

        HideFilters ->
            ( { model | state = model.state |> State.withFilters State.Hidden }, Cmd.none )

        DecrementBeer beer ->
            let
                newBeers =
                    Model.BeerList.decrement beer model.beers
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
                    Model.BeerList.increment beer model.beers
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
                    Model.BeerList.delete beer model.beers
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
            , Cmd.none
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
                    Model.BeerList.addOrUpdate (BeerForm.toBeer model.beerForm) model.beers
            in
                ( { model
                    | beers = newBeers
                    , beerForm = BeerForm.empty model.beers
                    , state = model.state |> State.withChanges |> State.withBeerForm State.Hidden
                    , filters = model.filters |> Filter.setContext newBeers
                  }
                , Cmd.none
                )

        Noop ->
            ( model, Cmd.none )
