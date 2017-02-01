module Update exposing (update)

import Messages exposing (Msg(..))
import Commands
import Ports
import Model exposing (Model)
import Model.State as State exposing (Network(..))
import Model.Auth exposing (AuthStatus(..))
import Model.BeerForm as BeerForm
import Model.Filter as Filter
import Model.BeerList
import Model.Beer as Beer


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

        RetrievedBeerList (Err _) ->
            ( { model
                | state =
                    model.state
                        |> State.withError "Unable to load beer list"
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

        ClearFilters ->
            ( { model | filters = Filter.empty model.beers }, Cmd.none )

        UpdateFilters value ->
            ( { model | filters = model.filters |> Filter.setValue value }, Cmd.none )

        DecrementBeer beer ->
            ( { model
                | beers = Model.BeerList.decrement beer model.beers
                , state = model.state |> State.withChanges
              }
            , Cmd.none
            )

        IncrementBeer beer ->
            ( { model
                | beers = Model.BeerList.increment beer model.beers
                , state = model.state |> State.withChanges
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
                            Model.BeerList.add beer model.beers
                    in
                        ( { model
                            | beers = newBeers
                            , beerForm = Nothing
                            , state = model.state |> State.withChanges
                            , filters = model.filters |> Filter.setContext newBeers
                          }
                        , Cmd.none
                        )
