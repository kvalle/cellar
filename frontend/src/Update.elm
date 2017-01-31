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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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

        ChangeTab tab ->
            ( { model | tab = tab }, Cmd.none )

        ClearFilter ->
            ( { model | filters = Filter.empty model.beers }, Cmd.none )

        UpdateFilter value ->
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

        SaveBeers ->
            ( { model | state = State.withNetwork Saving model.state }
            , Commands.saveBeers model.env model.auth model.beers
            )

        LoadBeers ->
            ( { model | state = State.withNetwork Loading model.state }
            , Commands.fetchBeers model.env model.auth
            )

        UpdateBeerForm input ->
            ( { model | beerForm = model.beerForm |> BeerForm.setInput input }, Cmd.none )

        SubmitBeerForm ->
            case BeerForm.toBeer model.beerForm of
                Just beer ->
                    let
                        newBeers =
                            Model.BeerList.add beer model.beers
                    in
                        ( { model
                            | beers = newBeers
                            , beerForm = BeerForm.empty
                            , filters = model.filters |> Filter.setContext newBeers
                            , state = model.state |> State.withChanges
                          }
                        , Cmd.none
                        )

                Nothing ->
                    ( { model | beerForm = BeerForm.markSubmitted model.beerForm }, Cmd.none )

        ClearBeerForm ->
            ( { model | beerForm = BeerForm.empty }, Cmd.none )

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
