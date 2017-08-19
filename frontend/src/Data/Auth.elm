module Data.Auth exposing (..)

import Json.Decode exposing (Value, field)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode as Decode exposing (Decoder, maybe, list, string, bool)
import Json.Decode.Pipeline exposing (decode, required, optional)


type AuthStatus
    = LoggedIn Session
    | LoggedOut



{-
   Session represent the user loggin session. IdToken is the JWT token
   from Auth0 representing the current login session.
-}


type alias Session =
    { token : IdToken
    , profile : Profile
    }


type alias IdToken =
    String


sessionDecoder : Json.Decode.Decoder Session
sessionDecoder =
    Json.Decode.map2 Session
        (field "token" Json.Decode.string)
        (field "profile" profileDecoder)



{-
   Profile class matching user info in Auth0. For a reference of possible
   fields, see https://auth0.com/docs/user-profile/user-profile-structure
-}


type alias Profile =
    { email : String
    , email_verified : Bool
    , name : String
    , picture : String
    , user_id : String
    , username : String
    }


profileDecoder : Decoder Profile
profileDecoder =
    decode Profile
        |> required "email" string
        |> required "email_verified" bool
        |> required "name" string
        |> required "picture" string
        |> required "user_id" string
        |> required "username" string
