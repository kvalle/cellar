module Subscriptions exposing (subscriptions)

import Auth
import Messages


subscriptions : model -> Sub Messages.Msg
subscriptions model =
    Auth.loginResult Messages.LoginResult
