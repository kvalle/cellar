module Data.AppState exposing (..)

import Page.BeerList.Model.Environment
import Data.Auth


type alias AppState =
    { environment : Page.BeerList.Model.Environment.Environment
    , auth : Data.Auth.AuthStatus
    }
