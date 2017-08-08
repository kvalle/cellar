module Page.BeerList.View exposing (view)

import Page.BeerList.Messages as Msg exposing (Msg)
import Page.BeerList.Model exposing (Model)
import Page.BeerList.Model.State as State
import Page.BeerList.Model.Beer
import Page.BeerList.View.BeerList exposing (viewBeerList)
import Page.BeerList.View.Filters exposing (viewFilters)
import Page.BeerList.View.BeerForm exposing (viewBeerForm)
import Page.BeerList.View.Json exposing (viewJsonModal)
import Page.BeerList.View.Help exposing (viewHelpDialog)
import Html exposing (..)
import Html.Events exposing (onClick, onInput, onWithOptions, defaultOptions)
import Html.Attributes exposing (id, class, type_, for, src, title, value, style)


view : Model -> Html Msg
view model =
    div []
        [ viewBeerForm model
        , viewJsonModal model
        , viewHelpDialog model
        , div [ class "row" ]
            [ div [ class "main twelve columns" ]
                []
            ]
        , div [ class "row" ]
            [ div [ class "main twelve columns" ]
                [ div [ class "menu-actions" ]
                    [ viewButton "Add beer" "beer" (Msg.ShowForm Page.BeerList.Model.Beer.empty) True
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
