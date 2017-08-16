port module Ports exposing (..)

import Json.Decode
import Data.Auth exposing (Session)


port setSessionStorage : Session -> Cmd msg


port clearSessionStorage : () -> Cmd msg


port showAuth0Lock : () -> Cmd msg


port keyPressed : (Json.Decode.Value -> msg) -> Sub msg
