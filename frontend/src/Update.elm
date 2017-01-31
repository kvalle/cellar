module Update exposing (update)

import Messages exposing (Msg(..))
import Commands exposing (fetchBeers, saveBeers)
import Model exposing (Model)
import Model.State exposing (Changes(..), Network(..))
import Model.Auth exposing (AuthStatus(..))
import Model.BeerForm
import Model.Filter
import Update.Beer as Beer
import Update.Filter as Filter
import Update.BeerForm as BeerForm
import Ports


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RetrievedBeerList (Err _) ->
            ( { model
                | state =
                    model.state
                        |> Model.State.withError "Unable to load beer list"
                        |> Model.State.withNetwork Idle
              }
            , Cmd.none
            )

        RetrievedBeerList (Ok beers) ->
            ( { model
                | beers = beers
                , filters = Filter.setContext beers model.filters
                , state =
                    model.state
                        |> Model.State.withNetwork Idle
                        |> Model.State.withNoChanges
              }
            , Cmd.none
            )

        SavedBeerList (Ok _) ->
            ( { model
                | state =
                    model.state
                        |> Model.State.withNetwork Idle
                        |> Model.State.withNoChanges
              }
            , Cmd.none
            )

        SavedBeerList (Err _) ->
            ( { model
                | state =
                    model.state
                        |> Model.State.withError "Unable to store beer list"
                        |> Model.State.withNetwork Idle
              }
            , Cmd.none
            )

        ChangeTab tab ->
            ( { model | tab = tab }, Cmd.none )

        ClearFilter ->
            ( { model | filters = Filter.setContext model.beers Model.Filter.empty }, Cmd.none )

        UpdateFilter value ->
            ( { model | filters = Filter.setValue model.filters value }, Cmd.none )

        DecrementBeer beer ->
            ( { model
                | beers = Beer.decrement beer model.beers
                , state = model.state |> Model.State.withChanges
              }
            , Cmd.none
            )

        IncrementBeer beer ->
            ( { model
                | beers = Beer.increment beer model.beers
                , state = model.state |> Model.State.withChanges
              }
            , Cmd.none
            )

        DeleteBeer beer ->
            let
                newBeers =
                    Beer.delete beer model.beers
            in
                ( { model
                    | beers = newBeers
                    , state = model.state |> Model.State.withChanges
                    , filters = Filter.setContext newBeers model.filters
                  }
                , Cmd.none
                )

        SaveBeers ->
            ( { model | state = Model.State.withNetwork Saving model.state }
            , saveBeers model.env model.auth model.beers
            )

        LoadBeers ->
            ( { model | state = Model.State.withNetwork Loading model.state }
            , fetchBeers model.env model.auth
            )

        UpdateBeerForm input ->
            ( { model | beerForm = BeerForm.setInput input model.beerForm }, Cmd.none )

        SubmitBeerForm ->
            case BeerForm.toBeer model.beerForm of
                Just beer ->
                    let
                        newBeers =
                            Beer.add beer model.beers
                    in
                        ( { model
                            | beers = newBeers
                            , beerForm = Model.BeerForm.empty
                            , filters = Filter.setContext newBeers model.filters
                            , state = model.state |> Model.State.withChanges
                          }
                        , Cmd.none
                        )

                Nothing ->
                    ( { model | beerForm = BeerForm.markSubmitted model.beerForm }, Cmd.none )

        ClearBeerForm ->
            ( { model | beerForm = Model.BeerForm.empty }, Cmd.none )

        Login ->
            ( model
            , Ports.login ()
            )

        LoginResult userData ->
            ( { model | auth = LoggedIn userData }
            , fetchBeers model.env <| LoggedIn userData
            )

        Logout ->
            ( model
            , Ports.logout ()
            )

        LogoutResult _ ->
            ( { model | auth = LoggedOut, beers = [] }, Cmd.none )

        SetTableState newState ->
            ( { model | tableState = newState }, Cmd.none )
