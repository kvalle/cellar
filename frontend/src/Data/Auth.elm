module Data.Auth exposing (..)

import Json.Decode exposing (field)
import Json.Decode as Decode exposing (Value, field)
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


type AuthRedirect
    = NoRedirect
    | Redirect (Maybe Route)


type AuthStatus
    = LoggedIn UserData
    | LoggedOut AuthRedirect



---- DECODERS


userDataDecoder : Json.Decode.Decoder UserData
userDataDecoder =
    Json.Decode.map2 UserData
        (field "token" Json.Decode.string)
        (field "profile" profileDecoder)


profileDecoder : Json.Decode.Decoder User
profileDecoder =
    Json.Decode.map4 User
        (field "email" Json.Decode.string)
        (field "username" Json.Decode.string)
        (field "email_verified" Json.Decode.bool)
        (field "picture" Json.Decode.string)
