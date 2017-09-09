module Page.BeerList.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, for, id, src, style, title, type_, value)
import Html.Events exposing (defaultOptions, onClick, onInput, onWithOptions)
import Page.BeerList.Messages as Msg exposing (Msg)
import Page.BeerList.Model exposing (Model)
import Page.BeerList.Model.State as State
import Page.BeerList.View.BeerList exposing (viewBeerList)
import Page.BeerList.View.Filters exposing (viewFilters)
import Route


view : Model -> Html Msg
view model =
    div []
        [ div [ class "row" ]
            [ div [ class "main twelve columns" ]
                []
            ]
        , div [ class "row" ]
            [ div [ class "main twelve columns" ]
                [ div [ class "menu-actions" ]
                    [ viewLink "Add beer" "beer" Route.AddBeer True
                    , viewButton "Clear filters" "cancel" Msg.ClearFilters model.filters.active
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


viewLink : String -> String -> Route.Route -> Bool -> Html Msg
viewLink name icon route active =
    let
        attributes =
            if active then
                [ class "action", Route.href route ]
            else
                [ class "action disabled" ]
    in
        a attributes
            [ span []
                [ i [ class <| "icon-" ++ icon ] []
                , text name
                ]
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
