module View exposing (view)

import Messages as Msg exposing (Msg)
import Model exposing (Model)
import Model.State as State
import Model.Auth as Auth
import View.BeerList exposing (viewBeerList)
import View.Filters exposing (viewFilters)
import View.BeerForm exposing (viewBeerForm)
import Html exposing (..)
import Html.Events exposing (onClick, onInput, onWithOptions, defaultOptions)
import Html.Attributes exposing (id, class, type_, for, src, title, value)


view : Model -> Html Msg
view model =
    case model.auth of
        Auth.LoggedOut ->
            viewLoggedOut

        Auth.LoggedIn userData ->
            viewLoggedIn model


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
        [ viewBeerForm model
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
            [ div [ class "main nine columns" ]
                [ div [ class "menu-actions" ]
                    [ viewButton "Add beer" "beer" Msg.ShowAddBeerForm True
                    , viewButton "Save" "floppy" Msg.SaveBeers (model.state.changes == State.Changed)
                    , viewButton "Reset" "ccw" Msg.LoadBeers (model.state.changes == State.Changed)
                    , viewButton "Clear filters" "cancel" Msg.ClearFilters model.filters.active
                    , viewDisabledButton "Download" "download"
                    , viewDisabledButton "Upload" "upload"
                    ]
                , viewStatus model
                , viewErrors model.state.error
                , viewBeerList model.filters model.beers model.tableState
                ]
            , div [ class "sidebar three columns" ]
                [ h2 [] [ text "Filters" ]
                , viewFilters model.filters model.beers
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
