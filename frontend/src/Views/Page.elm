module Views.Page exposing (frame, ActivePage(..))

import Html exposing (..)
import Html.Attributes exposing (..)
import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(..), User)
import Html exposing (..)
import Html.Events exposing (onClick, onInput, onWithOptions, defaultOptions)
import Html.Attributes exposing (id, class, type_, for, src, title, value, style)
import Route


type ActivePage
    = BeerList
    | About
    | Other


frame : msg -> msg -> Bool -> AppState -> ActivePage -> Html msg -> Html msg
frame loginMsg logoutMsg isLoading appState activePage content =
    case appState.auth of
        LoggedIn _ ->
            div [ class "container" ]
                [ div [ class "row" ]
                    [ div [ class "header seven columns" ]
                        [ viewTitle ]
                    , div [ class "header five columns" ]
                        [ viewMenu logoutMsg appState.auth activePage
                        ]
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


viewMenu : msg -> AuthStatus -> ActivePage -> Html msg
viewMenu logoutMsg auth activePage =
    let
        userInfo =
            case auth of
                LoggedIn user ->
                    [ a [ class "menu-item logout", onClick logoutMsg ] [ text "Log out" ]
                    , span [ class "profile" ] [ text user.profile.username ]
                    , img [ src user.profile.picture ] []
                    ]

                _ ->
                    []

        viewMenuItem isActive route name =
            a [ classList [ ( "menu-item", True ), ( "active", isActive ) ], Route.href route ] [ text name ]

        menuItems =
            [ viewMenuItem (activePage == BeerList) Route.BeerList "Beers"
            , viewMenuItem (activePage == About) Route.About "About"
            ]
    in
        div [ class "menu" ] <| menuItems ++ userInfo


viewTitle : Html msg
viewTitle =
    h1 []
        [ i [ class "icon-beer" ] []
        , text "Cellar Index"
        ]
