module Subscriptions exposing (subscriptions)

import Auth
import Messages


subscriptions : model -> Sub Messages.Msg
subscriptions model =
    Sub.batch
        [ Auth.loginResult Messages.LoginResult
        , Auth.logoutResult Messages.LogoutResult
        ]
