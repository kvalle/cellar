module View exposing (view)

import Messages as Msg exposing (Msg)
import Model exposing (Model)
import Model.State as State
import Model.Auth as Auth
import Model.Tab as Tab
import View.BeerList exposing (viewBeerList)
import View.BeerForm exposing (viewBeerForm)
import View.Filter exposing (viewFilter)
import View.Tabs exposing (viewTabs)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, src, title)


view : Model -> Html Msg
view model =
    case model.auth of
        Auth.LoggedOut ->
            viewLoggedOut

        Auth.LoggedIn userData ->
            viewLoggedIn model



-- UNEXPOSED FUNCTIONS


viewLoggedOut : Html Msg
viewLoggedOut =
    div [ class "login" ]
        [ a [ class "button button-primary", onClick Msg.Login ]
            [ i [ class "icon-beer" ] []
            , text " Log in"
            ]
        ]


viewLoggedIn : Model -> Html Msg
viewLoggedIn model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "header seven columns" ]
                [ viewTitle ]
            , div [ class "header five columns" ]
                [ viewUserInfo model.auth ]
            ]
        , div [ class "row" ]
            [ div [ class "main twelve columns" ]
                []
            ]
        , div [ class "row" ]
            [ div [ class "main seven columns" ]
                [ div [ class "buttons" ]
                    [ viewButton "Save" "floppy" Msg.SaveBeers (model.changes == State.Changed)
                    , viewButton "Reset" "ccw" Msg.LoadBeers (model.changes == State.Changed)
                    , viewButton "Clear filters" "cancel" Msg.ClearFilter model.filters.active
                    , viewDisabledButton "Download" "download"
                    , viewDisabledButton "Upload" "upload"
                    ]
                , viewStatus model
                , viewErrors model.error
                , viewBeerList model.filters model.beers
                ]
            , div [ class "sidebar five columns" ]
                [ viewTabs model.tab
                , div [ class "content" ]
                    [ case model.tab of
                        Tab.FilterTab ->
                            viewFilter model.filters

                        Tab.AddBeerTab ->
                            viewBeerForm model.beerForm
                    ]
                ]
            ]
        ]


viewDisabledButton : String -> String -> Html Msg
viewDisabledButton name icon =
    span [ class "action disabled", title "Not implemented yet" ]
        [ i [ class <| "icon-" ++ icon ] []
        , text name
        ]


viewButton : String -> String -> Msg -> Bool -> Html Msg
viewButton name icon msg active =
    let
        attributes =
            if active then
                [ class "action", onClick msg ]
            else
                [ class "action disabled" ]
    in
        span attributes
            [ i [ class <| "icon-" ++ icon ] []
            , text name
            ]


viewUserInfo : Auth.AuthStatus -> Html Msg
viewUserInfo auth =
    case auth of
        Auth.LoggedOut ->
            text ""

        Auth.LoggedIn user ->
            div [ class "user-info" ]
                [ img [ src user.profile.picture ] []
                , span [ class "profile" ] [ text user.profile.username ]
                , a [ class "logout", onClick Msg.Logout ] [ text "Log out" ]
                ]


viewErrors : Maybe String -> Html msg
viewErrors error =
    case error of
        Nothing ->
            text ""

        Just error ->
            div [ class "errors" ]
                [ text <| "Error: " ++ error ]


viewStatus : Model -> Html Msg
viewStatus model =
    div [ class "status-info" ]
        [ span [] <|
            case model.network of
                State.Saving ->
                    [ i [ class "icon-spinner animate-spin" ] []
                    , text "Saving…"
                    ]

                State.Loading ->
                    [ i [ class "icon-spinner animate-spin" ] []
                    , text "Loading…"
                    ]

                State.Idle ->
                    case model.changes of
                        State.Unchanged ->
                            [ text "" ]

                        State.Changed ->
                            [ text "You have unsaved changes" ]
        ]


viewTitle : Html Msg
viewTitle =
    h1 []
        [ i [ class "icon-beer" ] []
        , text "Cellar Index"
        ]
