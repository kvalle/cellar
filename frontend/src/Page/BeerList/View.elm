module View exposing (view)

import Messages as Msg exposing (Msg)
import Model exposing (Model)
import Model.State as State
import Model.Auth as Auth
import Model.Beer
import View.BeerList exposing (viewBeerList)
import View.Filters exposing (viewFilters)
import View.BeerForm exposing (viewBeerForm)
import View.Json exposing (viewJsonModal)
import View.Help exposing (viewHelpDialog)
import Html exposing (..)
import Html.Events exposing (onClick, onInput, onWithOptions, defaultOptions)
import Html.Attributes exposing (id, class, type_, for, src, title, value, style)


view : Model -> Html Msg
view model =
    case model.auth of
        Auth.Checking ->
            viewCheckingLogin

        Auth.LoggedOut ->
            viewLoggedOut

        Auth.LoggedIn userData ->
            viewLoggedIn model


viewLoggedOut : Html Msg
viewLoggedOut =
    div [ class "login login-button" ]
        [ a [ class "button button-primary", onClick Msg.Login ]
            [ i [ class "icon-beer" ] []
            , text " Log in"
            ]
        ]


viewCheckingLogin : Html Msg
viewCheckingLogin =
    div [ class "login login-loading" ]
        [ i [ class "icon-spinner animate-spin" ] []
        , text "Loading…"
        ]


viewLoggedIn : Model -> Html Msg
viewLoggedIn model =
    div [ class "container" ]
        [ viewBeerForm model
        , viewJsonModal model
        , viewHelpDialog model
        , div [ class "row" ]
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
            [ div [ class "main twelve columns" ]
                [ div [ class "menu-actions" ]
                    [ viewButton "Add beer" "beer" (Msg.ShowForm Model.Beer.empty) True
                    , viewButton "Save" "floppy" Msg.SaveBeers (model.state.changes == State.Changed)
                    , viewButton "Reset" "ccw" Msg.LoadBeers (model.state.changes == State.Changed)
                    , viewButton "Clear filters" "cancel" Msg.ClearFilters model.filters.active
                    , viewButton "Download JSON" "download" Msg.ShowJsonModal True
                    , viewFilterAction model
                    , viewFilters model
                    ]
                , viewStatus model
                , viewErrors model.state.error
                , viewBeerList model
                ]
            ]
        ]


viewFilterAction : Model -> Html Msg
viewFilterAction model =
    let
        attributes =
            case model.state.filters of
                State.Visible ->
                    [ class "action filter-action", onClick Msg.HideFilters ]

                State.Hidden ->
                    [ class "action filter-action", onClick Msg.ShowFilters ]
    in
        span attributes
            [ i [ class "icon-filter" ] []
            , text "Filter"
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
        Auth.LoggedIn user ->
            div [ class "user-info" ]
                [ img [ src user.profile.picture ] []
                , span [ class "profile" ] [ text user.profile.username ]
                , a [ class "logout", onClick Msg.Logout ] [ text "Log out" ]
                ]

        _ ->
            text ""


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
            case model.state.network of
                State.Saving ->
                    [ i [ class "icon-spinner animate-spin" ] []
                    , text "Saving…"
                    ]

                State.Loading ->
                    [ i [ class "icon-spinner animate-spin" ] []
                    , text "Loading…"
                    ]

                State.Idle ->
                    case model.state.changes of
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
