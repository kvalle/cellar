module Data.AppState exposing (..)

import Data.Auth exposing (AuthStatus)
import Page.BeerList.Model.Environment exposing (Environment)


type alias AppState =
    { environment : Environment
    , auth : AuthStatus
    }


setAuth : AuthStatus -> AppState -> AppState
setAuth auth appState =
    { appState | auth = auth }
