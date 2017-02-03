module Update exposing (update)

import Messages exposing (Msg(..))
import Commands
import Ports
import Model exposing (Model)
import Model.State as State exposing (Network(..))
import Model.Auth exposing (AuthStatus(..))
import Model.BeerForm as BeerForm
import Model.Filters as Filter
import Model.BeerList
import Model.Beer as Beer
import Debug


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

        SetTableState newState ->
            ( { model | tableState = newState }, Cmd.none )

        RetrievedBeerList (Err err) ->
            ( { model
                | state =
                    model.state
                        |> State.withError ("Unable to load beer list" ++ (Debug.log "err" (toString err)))
                        |> State.withNetwork Idle
              }
            , Cmd.none
            )

        RetrievedBeerList (Ok beers) ->
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

        ShowAddBeerForm ->
            ( { model | beerForm = Just Beer.empty }, Cmd.none )

        ShowEditBeerForm beer ->
            ( { model | beerForm = Just beer }, Cmd.none )

        HideBeerForm ->
            ( { model | beerForm = Nothing }, Cmd.none )

        UpdateBeerForm input ->
            ( { model | beerForm = model.beerForm |> BeerForm.withInput input }, Cmd.none )

        SubmitBeerForm ->
            case model.beerForm of
                Nothing ->
                    ( model, Cmd.none )

                Just beer ->
                    let
                        newBeers =
                            Model.BeerList.addOrUpdate beer model.beers
                    in
                        ( { model
                            | beers = newBeers
                            , beerForm = Nothing
                            , state = model.state |> State.withChanges
                            , filters = model.filters |> Filter.setContext newBeers
                          }
                        , Cmd.none
                        )
