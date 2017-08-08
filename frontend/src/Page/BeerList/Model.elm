module Page.BeerList.Model exposing (Model, init)

import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(..))
import Page.BeerList.Model.State
import Page.BeerList.Model.Auth
import Page.BeerList.Model.Filters
import Page.BeerList.Model.BeerList
import Page.BeerList.Model.BeerForm
import Page.BeerList.Model.Table
import Page.BeerList.Model.Environment exposing (Environment)
import Table
import Task
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Backend.Beers
import Http


type alias Model =
    { env : Page.BeerList.Model.Environment.Environment
    , auth : Page.BeerList.Model.Auth.AuthStatus
    , tableState : Table.State
    , beerForm : Page.BeerList.Model.BeerForm.BeerForm
    , filters : Page.BeerList.Model.Filters.Filters
    , state : Page.BeerList.Model.State.State
    , beers : Page.BeerList.Model.BeerList.BeerList
    }


init : AppState -> Task.Task PageLoadError Model
init appState =
    let
        model =
            Model
                appState.environment
                Page.BeerList.Model.Auth.Checking
                Page.BeerList.Model.Table.init
                Page.BeerList.Model.BeerForm.init
                Page.BeerList.Model.Filters.init
                Page.BeerList.Model.State.init

        loadBeers userData =
            Backend.Beers.get appState.environment userData |> Http.toTask

        handleLoadError _ =
            pageLoadError "Unable to load beer list :("
    in
        case appState.auth of
            LoggedIn userData ->
                Task.map model (loadBeers userData)
                    |> Task.mapError handleLoadError

            _ ->
                Task.fail <| handleLoadError "Need to be logged in to fetch beer list"
