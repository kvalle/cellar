module Page.BeerList.Model exposing (Model, init)

import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(..))
import Page.BeerList.Model.State
import Page.BeerList.Model.Filters
import Page.BeerList.Model.BeerList
import Page.BeerList.Model.Table
import Table
import Task
import Page.Errored
import Backend.Beers
import Http
import Page.BeerList.Model.Filters as Filters


type alias Model =
    { tableState : Table.State
    , filters : Page.BeerList.Model.Filters.Filters
    , state : Page.BeerList.Model.State.State
    , beers : Page.BeerList.Model.BeerList.BeerList
    }


init : AppState -> Task.Task Page.Errored.Model Model
init appState =
    let
        model =
            Model
                Page.BeerList.Model.Table.init
                Page.BeerList.Model.Filters.init
                Page.BeerList.Model.State.init

        loadBeers userData =
            Backend.Beers.get appState.environment userData |> Http.toTask

        calibrateFilters : Model -> Model
        calibrateFilters model =
            { model | filters = model.filters |> Filters.setContext model.beers }

        handleLoadError _ =
            "Unable to load beer list :("
    in
        case appState.auth of
            LoggedIn userData ->
                Task.map model (loadBeers userData)
                    |> Task.map calibrateFilters
                    |> Task.mapError handleLoadError

            LoggedOut ->
                Task.fail <| handleLoadError "Need to be logged in to fetch beer list"
