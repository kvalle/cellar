module Main exposing (..)

import Messages exposing (Msg(..))
import Subscriptions
import Model exposing (Model)
import Model.State exposing (State(..))
import Model.Auth exposing (AuthStatus(..))
import Model.Tab exposing (Tab(..))
import Model.Environment exposing (envFromLocation)
import View
import Update
import Update.Filter as Filter
import Update.BeerForm as BeerForm
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
    ( Model [] BeerForm.empty Filter.empty Nothing FilterTab Saved LoggedOut (envFromLocation flags.location)
    , Cmd.none
    )


type alias Flags =
    { location : String }
