port module Ports exposing (..)

import Model.Auth exposing (UserData)


port login : () -> Cmd msg


port loginResult : (UserData -> msg) -> Sub msg


port logout : () -> Cmd msg


port logoutResult : (() -> msg) -> Sub msg
