module Subscriptions exposing (subscriptions)

import Ports
import Page.BeerList.Messages
import Model.KeyEvent exposing (keyEventDecoder)
import Json.Decode exposing (decodeValue)


subscriptions : model -> Sub Messages.Msg
subscriptions model =
    Sub.batch
        [ Ports.loginResult Messages.LoginResult
        , Ports.logoutResult Messages.LogoutResult
        , Ports.keyPressed (Messages.KeyPressed << decodeValue keyEventDecoder)
        ]
