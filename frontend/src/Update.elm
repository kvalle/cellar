module Update exposing (update)

import Messages exposing (Msg(..))
import Commands exposing (fetchBeers, saveBeers)
import Model exposing (Model)
import Model.State exposing (State(..))
import Model.Auth exposing (AuthStatus(..))
import Update.Beer as Beer
import Update.Filter as Filter
import Update.BeerForm as BeerForm
import Ports


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RetrievedBeerList (Err _) ->
            ( { model | error = Just "Unable to load beer list" }, Cmd.none )

        RetrievedBeerList (Ok beers) ->
            ( { model
                | beers = beers
                , filters = Filter.setContext beers model.filters
                , state = Saved
              }
            , Cmd.none
            )

        SavedBeerList (Ok _) ->
            ( { model | state = Saved }, Cmd.none )

        SavedBeerList (Err _) ->
            ( { model | error = Just "Unable to store beer list", state = Unsaved }, Cmd.none )

        ChangeTab tab ->
            ( { model | tab = tab }, Cmd.none )

        ClearFilter ->
            ( { model | filters = Filter.setContext model.beers Filter.empty }, Cmd.none )

        UpdateFilter value ->
            ( { model | filters = Filter.setValue model.filters value }, Cmd.none )

        DecrementBeer beer ->
            ( { model
                | beers = Beer.decrement beer model.beers
                , state = Unsaved
              }
            , Cmd.none
            )

        IncrementBeer beer ->
            ( { model
                | beers = Beer.increment beer model.beers
                , state = Unsaved
              }
            , Cmd.none
            )

        SaveBeers ->
            case model.auth of
                LoggedOut ->
                    ( { model | error = Just "You are not logged in" }, Cmd.none )

                LoggedIn userData ->
                    ( { model | state = Saving }, saveBeers model.env userData.token model.beers )

        UpdateBeerForm input ->
            ( { model | beerForm = BeerForm.setInput input model.beerForm }, Cmd.none )

        SubmitBeerForm ->
            case BeerForm.toBeer model.beerForm of
                Just beer ->
                    let
                        beerList =
                            Beer.add beer model.beers
                    in
                        ( { model
                            | beers = beerList
                            , beerForm = BeerForm.empty
                            , filters = Filter.setContext beerList model.filters
                            , state = Unsaved
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
            ( { model | auth = LoggedIn userData }, fetchBeers model.env userData.token )

        Logout ->
            ( model, Ports.logout () )

        LogoutResult _ ->
            ( { model | auth = LoggedOut, beers = [] }, Cmd.none )
