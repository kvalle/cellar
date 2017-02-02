module View.Filters exposing (viewFilters)

import Messages exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Model.Filter exposing (Filters, FilterValue(..))
import Model.Beer exposing (Beer)
import Set
import MultiSelect


viewFilters : Filters -> List Beer -> Html Msg
viewFilters filters beers =
    div [ class "filter-form" ]
        [ textFilter filters beers
        , ageFilter filters beers
        , styleFilter filters beers
        , clearButton filters
        ]


textFilter : Filters -> List Beer -> Html Msg
textFilter filters beers =
    div []
        [ label [ for "text-filter-input" ] [ text "Matching text" ]
        , input
            [ type_ "search"
            , id "text-filter"
            , onInput (\val -> (UpdateFilters (TextMatches val)))
            , value filters.textMatch
            , class "u-full-width"
            ]
            []
        ]


ageFilter : Filters -> List Beer -> Html Msg
ageFilter filters beers =
    div []
        [ label [ for "age-filter-input" ] [ text <| "Made in " ++ (toString filters.olderThan) ++ " or earlier" ]
        , input
            [ type_ "range"
            , id "age-filter-input"
            , class "u-full-width"
            , Html.Attributes.min <| toString <| Tuple.first filters.yearRange
            , Html.Attributes.max <| toString <| Tuple.second filters.yearRange
            , value <| toString filters.olderThan
            , onInput (\val -> (UpdateFilters (OlderThan val)))
            ]
            []
        ]


styleFilter : Filters -> List Beer -> Html Msg
styleFilter filters beers =
    div []
        [ label [ for "style-filter-input" ] [ text "With style" ]
        , MultiSelect.multiSelect
            (let
                options =
                    MultiSelect.defaultOptions (\styles -> (UpdateFilters (Styles styles)))

                toItem text =
                    { value = text, text = text, enabled = True }

                styles =
                    beers |> Set.toList << Set.fromList << List.map .style
             in
                { options | items = List.map toItem styles }
            )
            [ class "u-full-width" ]
            filters.styles
        ]


clearButton : Filters -> Html Msg
clearButton filters =
    let
        attributes =
            if filters.active then
                [ onClick ClearFilters, class "button-primary" ]
            else
                [ class "button-disabled" ]
    in
        button attributes
            [ text "Clear filters"
            , i [ class "icon-cancel" ] []
            ]
