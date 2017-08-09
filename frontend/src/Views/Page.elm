module Views.Page exposing (frame)

import Html exposing (..)
import Html.Attributes exposing (..)
import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(..), User)
import Html exposing (..)
import Html.Events exposing (onClick, onInput, onWithOptions, defaultOptions)
import Html.Attributes exposing (id, class, type_, for, src, title, value, style)


frame : msg -> msg -> Bool -> AppState -> Html msg -> Html msg
frame loginMsg logoutMsg isLoading appState content =
    case appState.auth of
        LoggedIn _ ->
            div [ class "container" ]
                [ div [ class "row" ]
                    [ div [ class "header seven columns" ]
                        [ viewTitle ]
                    , div [ class "header five columns" ]
                        [ viewUserInfo logoutMsg appState.auth ]
                    ]
                , content
                , div [] [ text "footer" ]
                ]

        LoggedOut _ ->
            div [ class "login login-button" ]
                [ a [ class "button button-primary", onClick loginMsg ]
                    [ i [ class "icon-beer" ] []
                    , text " Log in"
                    ]
                ]

        Checking _ ->
            div [ class "login login-loading" ]
                [ i [ class "icon-spinner animate-spin" ] []
                , text "Loading…"
                ]


viewUserInfo : msg -> AuthStatus -> Html msg
viewUserInfo logoutMsg auth =
    case auth of
        LoggedIn user ->
            div [ class "user-info" ]
                [ img [ src user.profile.picture ] []
                , span [ class "profile" ] [ text user.profile.username ]
                , a [ class "logout", onClick logoutMsg ] [ text "Log out" ]
                ]

        _ ->
            text ""


viewTitle : Html msg
viewTitle =
    h1 []
        [ i [ class "icon-beer" ] []
        , text "Cellar Index"
        ]
