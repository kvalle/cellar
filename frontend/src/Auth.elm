port module Auth exposing (..)


type alias User =
    { email : String
    , email_verified : Bool
    , picture : String
    }


type alias UserData =
    { token : String
    , profile : User
    }


type AuthStatus
    = LoggedOut
    | LoggedIn UserData


port login : () -> Cmd msg


port loginResult : (UserData -> msg) -> Sub msg


port logout : () -> Cmd msg


port logoutResult : (() -> msg) -> Sub msg
