module Subscriptions exposing (subscriptions)

import Ports
import Messages
import Keyboard


subscriptions : model -> Sub Messages.Msg
subscriptions model =
    Sub.batch
        [ Ports.loginResult Messages.LoginResult
        , Ports.logoutResult Messages.LogoutResult
        , Keyboard.downs Messages.KeyPressed
        ]
