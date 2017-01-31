module Update exposing (update)

import Messages exposing (Msg(..))
import Commands
import Ports
import Model exposing (Model)
import Model.State exposing (Network(..), withNetwork, withChanges, withNoChanges, withError)
import Model.Auth exposing (AuthStatus(..))
import Model.BeerForm exposing (markSubmitted, setInput, toBeer)
import Model.Filter exposing (setContext, setValue)
import Update.Beer


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RetrievedBeerList (Err _) ->
            ( { model
                | state =
                    model.state
                        |> withError "Unable to load beer list"
                        |> withNetwork Idle
              }
            , Cmd.none
            )

        RetrievedBeerList (Ok beers) ->
            ( { model
                | beers = beers
                , filters = model.filters |> setContext beers
                , state =
                    model.state
                        |> withNetwork Idle
                        |> withNoChanges
              }
            , Cmd.none
            )

        SavedBeerList (Ok _) ->
            ( { model
                | state =
                    model.state
                        |> withNetwork Idle
                        |> withNoChanges
              }
            , Cmd.none
            )

        SavedBeerList (Err _) ->
            ( { model
                | state =
                    model.state
                        |> withError "Unable to store beer list"
                        |> withNetwork Idle
              }
            , Cmd.none
            )

        ChangeTab tab ->
            ( { model | tab = tab }, Cmd.none )

        ClearFilter ->
            ( { model | filters = Model.Filter.empty model.beers }, Cmd.none )

        UpdateFilter value ->
            ( { model | filters = model.filters |> setValue value }, Cmd.none )

        DecrementBeer beer ->
            ( { model
                | beers = Update.Beer.decrement beer model.beers
                , state = model.state |> withChanges
              }
            , Cmd.none
            )

        IncrementBeer beer ->
            ( { model
                | beers = Update.Beer.increment beer model.beers
                , state = model.state |> withChanges
              }
            , Cmd.none
            )

        DeleteBeer beer ->
            let
                newBeers =
                    Update.Beer.delete beer model.beers
            in
                ( { model
                    | beers = newBeers
                    , state = model.state |> withChanges
                    , filters = model.filters |> setContext newBeers
                  }
                , Cmd.none
                )

        SaveBeers ->
            ( { model | state = withNetwork Saving model.state }
            , Commands.saveBeers model.env model.auth model.beers
            )

        LoadBeers ->
            ( { model | state = withNetwork Loading model.state }
            , Commands.fetchBeers model.env model.auth
            )

        UpdateBeerForm input ->
            ( { model | beerForm = model.beerForm |> setInput input }, Cmd.none )

        SubmitBeerForm ->
            case toBeer model.beerForm of
                Just beer ->
                    let
                        newBeers =
                            Update.Beer.add beer model.beers
                    in
                        ( { model
                            | beers = newBeers
                            , beerForm = Model.BeerForm.empty
                            , filters = model.filters |> setContext newBeers
                            , state = model.state |> withChanges
                          }
                        , Cmd.none
                        )

                Nothing ->
                    ( { model | beerForm = markSubmitted model.beerForm }, Cmd.none )

        ClearBeerForm ->
            ( { model | beerForm = Model.BeerForm.empty }, Cmd.none )

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
