module View.Filters exposing (viewFilters)

import Messages exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Model.Filters exposing (Filters, FilterValue(..))
import Model.Beer exposing (Beer)
import Set
import MultiSelect


viewFilters : Filters -> List Beer -> Html Msg
viewFilters filters beers =
    div [ class "filter-form" ]
        [ textFilter filters beers
        , yearMaxFilter filters beers
        , styleFilter filters beers
        , countMinFilter filters beers
        , clearButton filters
        ]


textFilter : Filters -> List Beer -> Html Msg
textFilter filters beers =
    div []
        [ label [ for "text-filter-input" ] [ text "Matching text" ]
        , input
            [ type_ "search"
            , id "text-filter"
            , onInput <| UpdateFilters << Text
            , value filters.textMatch
            , class "u-full-width"
            ]
            []
        ]


yearMaxFilter : Filters -> List Beer -> Html Msg
yearMaxFilter filters beers =
    div []
        [ label [ for "age-filter-input" ] [ text <| "Made in " ++ (toString filters.yearMax) ++ " or earlier" ]
        , input
            [ type_ "range"
            , id "age-filter-input"
            , class "u-full-width"
            , Html.Attributes.min <| toString <| Tuple.first filters.yearRange
            , Html.Attributes.max <| toString <| Tuple.second filters.yearRange
            , value <| toString filters.yearMax
            , onInput <| UpdateFilters << YearMax
            ]
            []
        ]


countMinFilter : Filters -> List Beer -> Html Msg
countMinFilter filters beers =
    div []
        [ label [ for "count-min-filter-input" ] [ text <| "At least " ++ (toString filters.countMin) ++ " bottles/cans" ]
        , input
            [ type_ "range"
            , id "count-min-filter-input"
            , class "u-full-width"
            , Html.Attributes.min <| toString <| Tuple.first filters.countRange
            , Html.Attributes.max <| toString <| Tuple.second filters.countRange
            , value <| toString filters.countMin
            , onInput <| UpdateFilters << CountMin
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
                    MultiSelect.defaultOptions <| UpdateFilters << Styles

                toItem text =
                    { value = text, text = text, enabled = True }

                styles =
                    beers |> List.map .style |> Set.fromList |> Set.toList
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
