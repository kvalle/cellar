module Model exposing (..)

import Model.State
import Model.Auth
import Model.Filters
import Model.BeerList
import Model.BeerForm
import Model.Table
import Model.Environment exposing (Environment)
import Table


type alias Model =
    { env : Model.Environment.Environment
    , auth : Model.Auth.AuthStatus
    , beers : Model.BeerList.BeerList
    , tableState : Table.State
    , beerForm : Model.BeerForm.BeerForm
    , filters : Model.Filters.Filters
    , state : Model.State.State
    }


init : Environment -> Model
init env =
    Model
        env
        Model.Auth.Checking
        Model.BeerList.init
        Model.Table.init
        Model.BeerForm.init
        Model.Filters.init
        Model.State.init
