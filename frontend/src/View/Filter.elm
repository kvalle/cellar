module View.Filter exposing (viewFilter)

import Messages exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Model.Filter exposing (Filters, FilterValue(..))
import Model.Beer exposing (Beer)
import Set
import MultiSelect


viewFilter : Filters -> List Beer -> Html Msg
viewFilter filters beers =
    div [ class "filter-form" ]
        [ label [ for "text-filter-input" ] [ text "Matching text" ]
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
        , label [ for "style-filter-input" ] [ text "With style" ]
        , MultiSelect.multiSelect
            (let
                options =
                    MultiSelect.defaultOptions (\styles -> (UpdateFilter (Styles styles)))

                toItem text =
                    { value = text, text = text, enabled = True }

                styles =
                    beers |> Set.toList << Set.fromList << List.map .style
             in
                { options | items = List.map toItem styles }
            )
            [ class "u-full-width" ]
            filters.styles
        , button [ onClick ClearFilter ]
            [ text "Clear filters"
            , i [ class "icon-cancel" ] []
            ]
        ]
