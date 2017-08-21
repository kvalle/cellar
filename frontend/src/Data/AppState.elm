module Data.AppState exposing (AppState, setAuth, decodeFromJson)

import Json.Decode exposing (field)
import Json.Decode as Decode exposing (Value, field)
import Data.Auth exposing (AuthStatus)
import Data.Environment exposing (Environment)


type alias AppState =
    { environment : Environment
    , auth : AuthStatus
    }


setAuth : AuthStatus -> AppState -> AppState
setAuth auth appState =
    { appState | auth = auth }


decodeFromJson : Value -> AppState
decodeFromJson json =
    let
        defaultAppState =
            { environment = Data.Environment.Unknown
            , auth = Data.Auth.LoggedOut
            }
    in
        json
            |> Decode.decodeValue appStateDecoder
            |> Result.withDefault defaultAppState


appStateDecoder : Json.Decode.Decoder AppState
appStateDecoder =
    let
        toAuthStatus maybeUserData =
            maybeUserData
                |> Maybe.map Data.Auth.LoggedIn
                |> Maybe.withDefault Data.Auth.LoggedOut
    in
        Json.Decode.map2 AppState
            (Json.Decode.map Data.Environment.fromHostString (field "location" Json.Decode.string))
            (Json.Decode.map toAuthStatus (Json.Decode.maybe (field "session" Data.Auth.sessionDecoder)))
