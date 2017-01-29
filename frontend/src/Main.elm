module Main exposing (..)

import Messages exposing (Msg(..))
import Subscriptions exposing (subscriptions)
import Model exposing (Model)
import Model.State exposing (State(..))
import Model.Auth exposing (AuthStatus(..))
import Model.Tab exposing (Tab(..))
import Model.Environment exposing (envFromLocation)
import View.BeerList exposing (viewBeerList)
import View.BeerForm exposing (viewBeerForm)
import View.Filter exposing (viewFilter)
import View.Tabs exposing (viewTabs)
import View exposing (buttonWithIcon)
import Update
import Update.Filter as Filter
import Update.BeerForm as BeerForm
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, src)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = Update.update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model [] BeerForm.empty Filter.empty Nothing FilterTab Saved LoggedOut (envFromLocation flags.location)
    , Cmd.none
    )


type alias Flags =
    { location : String }



-- VIEW


view : Model -> Html Msg
view model =
    case model.auth of
        LoggedOut ->
            viewLoggedOut

        LoggedIn userData ->
            viewLoggedIn model


viewLoggedOut : Html Msg
viewLoggedOut =
    div [ class "login" ]
        [ button [ onClick Login ] [ text "Log in" ]
        ]


viewHeader : AuthStatus -> Html Msg
viewHeader auth =
    case auth of
        LoggedOut ->
            text ""

        LoggedIn user ->
            div [ class "user-info" ]
                [ img [ src user.profile.picture ] []
                , span [ class "profile" ] [ text user.profile.username ]
                , a [ class "logout", onClick Logout ] [ text "Log out" ]
                ]


viewLoggedIn : Model -> Html Msg
viewLoggedIn model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "header twelve columns" ]
                [ viewHeader model.auth ]
            ]
        , div [ class "row" ]
            [ div [ class "main seven columns" ]
                [ viewTitle ]
            , div [ class "sidebar five columns" ]
                [ viewTabs model.tab
                ]
            ]
        , div [ class "row" ]
            [ div [ class "main seven columns" ]
                [ viewBeerList model.filters model.beers
                , viewSaveButton model
                , viewErrors model.error
                ]
            , div [ class "sidebar five columns" ]
                [ case model.tab of
                    FilterTab ->
                        viewFilter model.filters

                    AddBeerTab ->
                        viewBeerForm model.beerForm
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


viewSaveButton : Model -> Html Msg
viewSaveButton model =
    div []
        [ buttonWithIcon "Save" "floppy" SaveBeers "button-primary"
        , span [ class "save-status" ] <|
            case model.state of
                Saved ->
                    [ text "" ]

                Unsaved ->
                    [ text "You have unsaved changes" ]

                Saving ->
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
