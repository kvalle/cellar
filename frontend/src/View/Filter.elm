module View.Filter exposing (viewFilter)

import Messages exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Model.Filter exposing (Filters, FilterValue(..))


viewFilter : Filters -> Html Msg
viewFilter filters =
    div [ class "filter-form" ]
        [ label [ for "text-filter-input" ] [ text "Text filter" ]
        , input
            [ type_ "search"
            , id "text-filter"
            , onInput (\val -> (UpdateFilter (TextMatches val)))
            , value filters.textMatch
            , class "u-full-width"
            ]
            []
        , label [ for "age-filter-input" ] [ text <| "Made in " ++ (toString filters.olderThan) ++ " or earlier" ]
        , input
            [ type_ "range"
            , id "age-filter-input"
            , class "u-full-width"
            , Html.Attributes.min <| toString <| Tuple.first filters.yearRange
            , Html.Attributes.max <| toString <| Tuple.second filters.yearRange
            , value <| toString filters.olderThan
            , onInput (\val -> (UpdateFilter (OlderThan val)))
            ]
            []
        , button [ onClick ClearFilter ]
            [ text "Clear"
            , i [ class "icon-cancel" ] []
            ]
        ]
