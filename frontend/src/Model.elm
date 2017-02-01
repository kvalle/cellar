module Model exposing (..)

import Model.State
import Model.Auth
import Model.Filter
import Model.BeerList
import Model.BeerForm
import Model.Environment exposing (Environment)
import Table


type alias Model =
    { env : Model.Environment.Environment
    , auth : Model.Auth.AuthStatus
    , beers : Model.BeerList.BeerList
    , tableState : Table.State
    , beerForm : Model.BeerForm.BeerForm
    , filters : Model.Filter.Filters
    , state : Model.State.State
    }


init : Environment -> Model
init env =
    Model
        env
        Model.Auth.LoggedOut
        []
        (Table.initialSort "Brewery")
        Nothing
        Model.Filter.init
        Model.State.init
