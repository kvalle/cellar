module Backend.Auth exposing (getAuthedUserProfile)

import Data.Auth
import Http exposing (Request)
import Json.Encode as Encode


auth0endpoint : String
auth0endpoint =
    "https://cellar.eu.auth0.com"


getAuthedUserProfile : Data.Auth.IdToken -> Request Data.Auth.Profile
getAuthedUserProfile idToken =
    Http.request
        { method = "POST"
        , headers = []
        , url = auth0endpoint ++ "/tokeninfo"
        , body =
            Http.jsonBody <|
                Encode.object [ ( "id_token", Encode.string idToken ) ]
        , expect = Http.expectJson Data.Auth.profileDecoder
        , timeout = Nothing
        , withCredentials = False
        }
