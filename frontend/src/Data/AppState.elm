module Data.AppState exposing (AppState, setAuth, decodeFromJson)

import Json.Decode exposing (field)
import Json.Decode as Decode exposing (Value, field)
import Route exposing (Route)
import Data.Auth exposing (AuthStatus)
import Data.Environment exposing (Environment)


type alias AppState =
    { environment : Environment
    , auth : AuthStatus
    }


setAuth : AuthStatus -> AppState -> AppState
setAuth auth appState =
    { appState | auth = auth }


decodeFromJson : Maybe Route.Route -> Value -> AppState
decodeFromJson defaultRoute json =
    let
        defaultAppState =
            { environment = Data.Environment.Unknown
            , auth = Data.Auth.LoggedOut (Data.Auth.Redirect defaultRoute)
            }
    in
        json
            |> Decode.decodeValue (appStateDecoder defaultRoute)
            |> Result.toMaybe
            |> Maybe.withDefault defaultAppState


appStateDecoder : Maybe Route.Route -> Json.Decode.Decoder AppState
appStateDecoder route =
    let
        toAuthStatus maybeUserData =
            maybeUserData
                |> Maybe.map Data.Auth.LoggedIn
                |> Maybe.withDefault (Data.Auth.LoggedOut (Data.Auth.Redirect route))
    in
        Json.Decode.map2 AppState
            (Json.Decode.map Data.Environment.fromHostString (field "location" Json.Decode.string))
            (Json.Decode.map toAuthStatus (Json.Decode.maybe (field "user" Data.Auth.userDataDecoder)))
