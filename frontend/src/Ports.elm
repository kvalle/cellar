port module Ports exposing (..)

import Json.Decode


port login : () -> Cmd msg


port logout : () -> Cmd msg


port logoutResult : (() -> msg) -> Sub msg


port keyPressed : (Json.Decode.Value -> msg) -> Sub msg
