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
    { beers : List Model.Beer.Beer
    , beerForm : Model.BeerForm.BeerForm
    , filters : Model.Filter.Filters
    , error : Maybe String
    , tab : Model.Tab.Tab
    , changes : Model.State.Changes
    , network : Model.State.Network
    , auth : Model.Auth.AuthStatus
    , env : Model.Environment.Environment
    , tableState : Table.State
    }


init : Environment -> Model
init env =
    Model
        []
        Model.BeerForm.empty
        Model.Filter.empty
        Nothing
        Model.Tab.FilterTab
        Model.State.Unchanged
        Model.State.Idle
        Model.Auth.LoggedOut
        env
        (Table.initialSort "Brewery")
