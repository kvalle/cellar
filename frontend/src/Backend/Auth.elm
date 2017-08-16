module Backend.Auth exposing (login, getAuthedUserProfile)

import Data.Auth exposing (IdToken, Session)
import Http exposing (Request)
import Json.Encode as Encode
import Task exposing (Task)


auth0endpoint : String
auth0endpoint =
    "https://cellar.eu.auth0.com"


login : Maybe IdToken -> Task String Session
login maybeToken =
    let
        getProfile token =
            getAuthedUserProfile token |> Http.toTask

        errorMsg =
            -- FIXME: better error message
            "Unable to login :("
    in
        case maybeToken of
            Just token ->
                Task.map (Session token) (getProfile token)
                    |> Task.mapError (\_ -> errorMsg)

            Nothing ->
                Task.fail errorMsg


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
