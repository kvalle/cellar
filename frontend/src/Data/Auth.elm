module Data.Auth exposing (..)

import Route exposing (Route)


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
    = LoggedIn UserData
    | LoggedOut (Maybe Route)
    | Checking (Maybe Route)
