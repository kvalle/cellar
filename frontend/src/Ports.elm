port module Ports exposing (..)

import Data.Auth exposing (UserData)
import Json.Decode


port login : () -> Cmd msg


port loginResult : (UserData -> msg) -> Sub msg


port logout : () -> Cmd msg


port logoutResult : (() -> msg) -> Sub msg


port keyPressed : (Json.Decode.Value -> msg) -> Sub msg
