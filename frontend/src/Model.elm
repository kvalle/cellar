module Model exposing (..)

import Model.State
import Model.Auth
import Model.Tab
import Model.Filter
import Model.Beer
import Model.BeerForm
import Model.Environment exposing (Environment)
import Table


type alias Model =
    { env : Model.Environment.Environment
    , auth : Model.Auth.AuthStatus
    , beers : List Model.Beer.Beer
    , tableState : Table.State
    , beerForm : Model.BeerForm.BeerForm
    , filters : Model.Filter.Filters
    , tab : Model.Tab.Tab
    , state : Model.State.State
    }


init : Environment -> Model
init env =
    Model
        env
        Model.Auth.LoggedOut
        []
        (Table.initialSort "Brewery")
        Model.BeerForm.init
        Model.Filter.init
        Model.Tab.FilterTab
        Model.State.init
