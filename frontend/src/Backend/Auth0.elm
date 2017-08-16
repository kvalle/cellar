module Backend.Auth0 exposing (IdToken, Profile, profileDecoder, getAuthedUserProfile)

import Http exposing (Request)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode as Decode exposing (Decoder, maybe, list, string, bool)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode


auth0endpoint : String
auth0endpoint =
    "https://cellar.eu.auth0.com"


type alias IdToken =
    String


getAuthedUserProfile : IdToken -> Request Profile
getAuthedUserProfile idToken =
    Http.request
        { method = "POST"
        , headers = []
        , url = auth0endpoint ++ "/tokeninfo"
        , body =
            Http.jsonBody <|
                Encode.object [ ( "id_token", Encode.string idToken ) ]
        , expect = Http.expectJson profileDecoder
        , timeout = Nothing
        , withCredentials = False
        }



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
