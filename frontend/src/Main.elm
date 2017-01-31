module Main exposing (..)

import Messages exposing (Msg)
import Subscriptions
import Model exposing (Model)
import Model.Environment
import View
import Update
import Html


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        environment =
            Model.Environment.fromLocation flags.location
    in
        ( Model.init environment, Cmd.none )


type alias Flags =
    { location : String }
