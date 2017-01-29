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
import View.Utils as Utils
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, src)


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


viewHeader : Auth.AuthStatus -> Html Msg
viewHeader auth =
    case auth of
        Auth.LoggedOut ->
            text ""

        Auth.LoggedIn user ->
            div [ class "user-info" ]
                [ img [ src user.profile.picture ] []
                , span [ class "profile" ] [ text user.profile.username ]
                , a [ class "logout", onClick Msg.Logout ] [ text "Log out" ]
                ]


viewLoggedIn : Model -> Html Msg
viewLoggedIn model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "header seven columns" ]
                [ viewTitle ]
            , div [ class "header five columns" ]
                [ viewHeader model.auth ]
            ]
        , div [ class "row" ]
            [ div [ class "main twelve columns" ]
                []
            ]
        , div [ class "row" ]
            [ div [ class "main seven columns" ]
                [ viewSaveState model.state
                , viewBeerList model.filters model.beers
                , viewErrors model.error
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


viewErrors : Maybe String -> Html msg
viewErrors error =
    div [ class "errors" ] <|
        case error of
            Nothing ->
                []

            Just error ->
                [ text error ]


viewSaveState : State.State -> Html Msg
viewSaveState state =
    div []
        [ span [ class "action", onClick Msg.SaveBeers ]
            [ i [ class "icon-floppy" ] []
            , text "Save"
            ]
        , span [ class "save-status" ] <|
            case state of
                State.Saved ->
                    [ text "" ]

                State.Unsaved ->
                    [ text "You have unsaved changes" ]

                State.Saving ->
                    [ i [ class "icon-spinner animate-spin" ] []
                    , text "Saving…"
                    ]
        ]


viewTitle : Html Msg
viewTitle =
    h1 []
        [ i [ class "icon-beer" ] []
        , text "Cellar Index"
        ]
