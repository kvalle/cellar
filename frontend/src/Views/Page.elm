module Views.Page exposing (frame)

import Html exposing (..)
import Html.Attributes exposing (..)
import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(..))
import Html exposing (..)
import Html.Events exposing (onClick, onInput, onWithOptions, defaultOptions)
import Html.Attributes exposing (id, class, type_, for, src, title, value, style)
import Route
import Data.Page exposing (ActivePage(..))


frame : msg -> msg -> Bool -> AppState -> ActivePage -> Html msg -> Html msg
frame loginMsg logoutMsg isLoading appState activePage content =
    div [ class "container" ]
        [ div [ class "row header" ]
            [ div [ class "seven columns" ]
                [ viewTitle ]
            , div [ class "five columns" ]
                [ viewMenu loginMsg logoutMsg appState.auth activePage
                ]
            ]
        , if isLoading then
            div [ class "loading-dialog login-loading" ]
                [ i [ class "icon-spinner animate-spin" ] []
                , text "Loading…"
                ]
          else
            content
        ]


viewMenu : msg -> msg -> AuthStatus -> ActivePage -> Html msg
viewMenu loginMsg logoutMsg auth activePage =
    let
        userInfo =
            case auth of
                LoggedIn user ->
                    [ a [ class "menu-item logout", onClick logoutMsg ] [ text "Log out" ]
                    , span [ class "profile" ] [ text user.profile.username ]
                    , img [ src user.profile.picture ] []
                    ]

                LoggedOut ->
                    [ a [ class "menu-item logout", onClick loginMsg ] [ text "Log in" ]
                    ]

        viewMenuItem isActive route name =
            a [ classList [ ( "menu-item", True ), ( "active", isActive ) ], Route.href route ] [ text name ]
    in
        div [ class "menu" ] <|
            [ viewMenuItem (activePage == Home) Route.Home "Home"
            , case auth of
                LoggedIn _ ->
                    viewMenuItem (activePage == BeerList) Route.BeerList "Beers"

                LoggedOut ->
                    text ""
            , span [] userInfo
            ]


viewTitle : Html msg
viewTitle =
    div [ class "logo" ]
        [ i [ class "icon-beer" ] []
        , text "Cellar Index"
        ]
