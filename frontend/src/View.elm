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
        [ button [ onClick Msg.Login ] [ text "Log in" ]
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
                [ viewButtons
                , viewNetwork model.network
                , viewChanges model.changes
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
    div [ class "errors" ] <|
        case error of
            Nothing ->
                []

            Just error ->
                [ text error ]


viewChanges : State.Changes -> Html Msg
viewChanges state =
    div []
        [ span [ class "save-status" ] <|
            case state of
                State.Unchanged ->
                    [ text "" ]

                State.Changed ->
                    [ text "You have unsaved changes" ]
        ]


viewNetwork : State.Network -> Html Msg
viewNetwork state =
    div []
        [ span [ class "save-status" ] <|
            case state of
                State.Saving ->
                    [ i [ class "icon-spinner animate-spin" ] []
                    , text "Saving…"
                    ]

                State.Loading ->
                    [ i [ class "icon-spinner animate-spin" ] []
                    , text "Loading…"
                    ]

                State.Idle ->
                    [ text "" ]
        ]


viewButtons : Html Msg
viewButtons =
    div [ class "buttons" ]
        [ span [ class "action", onClick Msg.SaveBeers ]
            [ i [ class "icon-floppy" ] []
            , text "Save"
            ]
        , span [ class "action", onClick Msg.LoadBeers ]
            [ i [ class "icon-ccw" ] []
            , text "Reset"
            ]
        , span [ class "action disabled", title "Not implemented yet" ]
            [ i [ class "icon-upload" ] []
            , text "Upload"
            ]
        , span [ class "action disabled", title "Not implemented yet" ]
            [ i [ class "icon-download" ] []
            , text "Download"
            ]
        ]


viewTitle : Html Msg
viewTitle =
    h1 []
        [ i [ class "icon-beer" ] []
        , text "Cellar Index"
        ]
