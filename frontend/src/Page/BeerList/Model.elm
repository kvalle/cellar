module Page.BeerList.Model exposing (Model, init)

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


type alias Model =
    { env : Page.BeerList.Model.Environment.Environment
    , auth : Page.BeerList.Model.Auth.AuthStatus
    , beers : Page.BeerList.Model.BeerList.BeerList
    , tableState : Table.State
    , beerForm : Page.BeerList.Model.BeerForm.BeerForm
    , filters : Page.BeerList.Model.Filters.Filters
    , state : Page.BeerList.Model.State.State
    }


init : Environment -> Task.Task PageLoadError Model
init env =
    Task.succeed <|
        Model
            env
            Page.BeerList.Model.Auth.Checking
            Page.BeerList.Model.BeerList.init
            Page.BeerList.Model.Table.init
            Page.BeerList.Model.BeerForm.init
            Page.BeerList.Model.Filters.init
            Page.BeerList.Model.State.init
