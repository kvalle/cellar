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


type alias Session =
    { token : String
    , profile : User
    }


type AuthRedirect
    = NoRedirect
    | Redirect Route


type AuthStatus
    = LoggedIn Session
    | LoggedOut AuthRedirect



---- DECODERS


sessionDecoder : Json.Decode.Decoder Session
sessionDecoder =
    Json.Decode.map2 Session
        (field "token" Json.Decode.string)
        (field "profile" profileDecoder)


profileDecoder : Json.Decode.Decoder User
profileDecoder =
    Json.Decode.map4 User
        (field "email" Json.Decode.string)
        (field "username" Json.Decode.string)
        (field "email_verified" Json.Decode.bool)
        (field "picture" Json.Decode.string)
