module Views.Page exposing (frame)

import Html exposing (..)
import Html.Attributes exposing (..)
import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(..), User)


frame : Bool -> AppState -> Html msg -> Html msg
frame isLoading appState content =
    let
        envString =
            toString appState.environment
    in
        div [ class "page-frame" ]
            [ div []
                [ span [] [ text <| "[" ++ envString ++ "] " ]
                , span [] [ text <| loginString appState.auth ]
                , if isLoading then
                    text " | loading..."
                  else
                    text " | header"
                ]
            , content
            , div [] [ text "footer" ]
            ]


loginString : AuthStatus -> String
loginString login =
    case login of
        LoggedOut ->
            "not logged in"

        LoggedIn userdata ->
            userdata.profile.email

        Checking ->
            "checking login"
