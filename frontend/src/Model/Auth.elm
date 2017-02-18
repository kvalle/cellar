module Model.Auth exposing (..)


type alias User =
    { email : String
    , username : String
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
    | Checking
