module Page.Json exposing (view, init, Model)

import Data.Beer exposing (Beer)
import Html exposing (..)
import Html.Attributes exposing (href, class)
import Json.Encode
import Page.Errored
import Task
import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(..))
import Backend.Beers
import Http


type alias Model =
    List Beer


init : AppState -> Task.Task Page.Errored.Model Model
init appState =
    case appState.auth of
        LoggedIn userData ->
            Backend.Beers.get appState.environment userData
                |> Http.toTask
                |> Task.mapError (\_ -> "Unable to load beer list :(")

        _ ->
            Task.fail <| "Need to be logged in to get beer list json"


view : Model -> Html msg
view model =
    let
        json =
            Json.Encode.list <| List.map Data.Beer.encoder model

        jsonString =
            Json.Encode.encode 4 json
    in
        div
            []
            [ p [] [ text "Here are the raw data of your beer cellar, formatted as JSON." ]
            , textarea [ class "json" ] [ text jsonString ]
            ]
