module Subscriptions exposing (subscriptions)

import Ports
import Messages


subscriptions : model -> Sub Messages.Msg
subscriptions model =
    Sub.batch
        [ Ports.loginResult Messages.LoginResult
        , Ports.logoutResult Messages.LogoutResult
        ]
