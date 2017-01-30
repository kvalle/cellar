module Update exposing (update)

import Messages exposing (Msg(..))
import Commands exposing (fetchBeers, saveBeers)
import Model exposing (Model)
import Model.State exposing (Changes(..), Network(..))
import Model.Auth exposing (AuthStatus(..))
import Update.Beer as Beer
import Update.Filter as Filter
import Update.BeerForm as BeerForm
import Ports


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RetrievedBeerList (Err _) ->
            ( { model
                | error = Just "Unable to load beer list"
                , network = Idle
              }
            , Cmd.none
            )

        RetrievedBeerList (Ok beers) ->
            ( { model
                | beers = beers
                , filters = Filter.setContext beers model.filters
                , changes = Unchanged
                , network = Idle
              }
            , Cmd.none
            )

        SavedBeerList (Ok _) ->
            ( { model | changes = Unchanged, network = Idle }, Cmd.none )

        SavedBeerList (Err _) ->
            ( { model
                | error = Just "Unable to store beer list"
                , network = Idle
              }
            , Cmd.none
            )

        ChangeTab tab ->
            ( { model | tab = tab }, Cmd.none )

        ClearFilter ->
            ( { model | filters = Filter.setContext model.beers Filter.empty }, Cmd.none )

        UpdateFilter value ->
            ( { model | filters = Filter.setValue model.filters value }, Cmd.none )

        DecrementBeer beer ->
            ( { model
                | beers = Beer.decrement beer model.beers
                , changes = Changed
              }
            , Cmd.none
            )

        IncrementBeer beer ->
            ( { model
                | beers = Beer.increment beer model.beers
                , changes = Changed
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
                    , changes = Changed
                    , filters = Filter.setContext newBeers model.filters
                  }
                , Cmd.none
                )

        SaveBeers ->
            ( { model | network = Saving }, saveBeers model.env model.auth model.beers )

        LoadBeers ->
            ( { model | network = Loading }, fetchBeers model.env model.auth )

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
                            , beerForm = BeerForm.empty
                            , filters = Filter.setContext newBeers model.filters
                            , changes = Changed
                          }
                        , Cmd.none
                        )

                Nothing ->
                    ( { model | beerForm = BeerForm.markSubmitted model.beerForm }, Cmd.none )

        ClearBeerForm ->
            ( { model | beerForm = BeerForm.empty }, Cmd.none )

        Login ->
            ( model, Ports.login () )

        LoginResult userData ->
            ( { model | auth = LoggedIn userData }, fetchBeers model.env <| LoggedIn userData )

        Logout ->
            ( model, Ports.logout () )

        LogoutResult _ ->
            ( { model | auth = LoggedOut, beers = [] }, Cmd.none )

        SetTableState newState ->
            ( { model | tableState = newState }, Cmd.none )
