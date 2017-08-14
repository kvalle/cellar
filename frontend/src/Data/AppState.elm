module Data.AppState exposing (..)

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


decodeFromJson : Value -> Maybe Route.Route -> AppState
decodeFromJson json defaultRoute =
    let
        defaultAppState =
            { environment = Data.Environment.Unknown
            , auth = Data.Auth.LoggedOut (Data.Auth.Redirect defaultRoute)
            }

        result =
            json |> Decode.decodeValue (appStateDecoder defaultRoute)

        _ =
            Debug.log "FLAGS" result
    in
        result
            |> Result.toMaybe
            |> Maybe.withDefault defaultAppState


appStateDecoder : Maybe Route.Route -> Json.Decode.Decoder AppState
appStateDecoder route =
    let
        fromLocation location =
            if String.contains "localhost" location then
                Data.Environment.Local
            else if String.contains "test.cellar.kjetilvalle.com" location then
                Data.Environment.Test
            else if String.contains "dev.cellar.kjetilvalle.com" location then
                Data.Environment.Dev
            else if String.contains "cellar.kjetilvalle.com" location then
                Data.Environment.Prod
            else
                Data.Environment.Unknown

        toAuthStatus maybeUserData =
            case maybeUserData of
                Just userData ->
                    Data.Auth.LoggedIn userData

                -- FIXME: should probably use route where app initiated
                Nothing ->
                    Data.Auth.LoggedOut (Data.Auth.Redirect route)

        locationDecoder =
            (Json.Decode.map fromLocation (field "location" Json.Decode.string))
    in
        Json.Decode.map2 AppState
            locationDecoder
            (Json.Decode.map toAuthStatus
                (Json.Decode.maybe <| field "user" userDataDecoder)
            )


profileDecoder : Json.Decode.Decoder Data.Auth.User
profileDecoder =
    Json.Decode.map4 Data.Auth.User
        (field "email" Json.Decode.string)
        (field "username" Json.Decode.string)
        (field "email_verified" Json.Decode.bool)
        (field "picture" Json.Decode.string)


userDataDecoder : Json.Decode.Decoder Data.Auth.UserData
userDataDecoder =
    Json.Decode.map2 Data.Auth.UserData
        (field "token" Json.Decode.string)
        (field "profile" profileDecoder)
