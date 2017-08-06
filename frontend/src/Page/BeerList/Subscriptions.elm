module Page.BeerList.Subscriptions exposing (subscriptions)

import Ports
import Page.BeerList.Messages
import Page.BeerList.Model.KeyEvent exposing (keyEventDecoder)
import Json.Decode exposing (decodeValue)


subscriptions : Sub Page.BeerList.Messages.Msg
subscriptions =
    Sub.batch
        [ Ports.loginResult Page.BeerList.Messages.LoginResult
        , Ports.logoutResult Page.BeerList.Messages.LogoutResult
        , Ports.keyPressed (Page.BeerList.Messages.KeyPressed << decodeValue keyEventDecoder)
        ]
