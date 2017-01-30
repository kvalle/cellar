module Model exposing (..)

import Model.State
import Model.Auth
import Model.Beer
import Model.BeerForm
import Model.Tab
import Model.Filter
import Model.Environment
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
