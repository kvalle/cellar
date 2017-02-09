module View.Filters exposing (viewFilters)

import Messages exposing (Msg(..))
import Model exposing (Model)
import Model.Filters exposing (Filters, FilterValue(..))
import Model.Beer exposing (Beer)
import Model.State exposing (DisplayState(..))
import View.HtmlExtra exposing (onKeyWithOptions, keys)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, defaultOptions)
import MultiSelect
import List.Extra


viewFilters : Model -> Html Msg
viewFilters model =
    case model.state.filters of
        Hidden ->
            text ""

        Visible ->
            div [ class "filter-parent" ]
                [ div [ class "filter-overlay", onClick HideFilters ] []
                , div [ class "filter-form" ]
                    [ textFilter model.filters model.beers
                    , yearMaxFilter model.filters model.beers
                    , styleFilter model.filters model.beers
                    , countMinFilter model.filters model.beers
                    , buttons model.filters
                    ]
                ]


textFilter : Filters -> List Beer -> Html Msg
textFilter filters beers =
    div []
        [ label [ for "text-filter-input" ] [ text "Matching text" ]
        , input
            [ type_ "search"
            , id "text-filter"
            , onInput <| UpdateFilters << Text
            , onKeyWithOptions { defaultOptions | preventDefault = True } keys.escape Noop
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
        [ label [ for "count-min-filter-input" ]
            [ let
                bottles =
                    if filters.countMin == 1 then
                        "bottle/can"
                    else
                        "bottles/cans"
              in
                text <| "At least " ++ (toString filters.countMin) ++ " " ++ bottles
            ]
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

                toText style count =
                    style ++ " (" ++ toString count ++ ")"

                toItem ( count, style ) =
                    { value = style, text = toText style count, enabled = True }

                styles =
                    beers
                        |> List.map .style
                        |> List.sort
                        |> List.Extra.group
                        |> List.map (\xs -> ( List.length xs, Maybe.withDefault "" (List.head xs) ))
             in
                { options | items = List.map toItem styles }
            )
            [ class "u-full-width" ]
            filters.styles
        ]


buttons : Filters -> Html Msg
buttons filters =
    div []
        [ useButton filters
        , clearButton filters
        ]


useButton : Filters -> Html Msg
useButton filters =
    let
        attributes =
            if filters.active then
                [ onClick ClearFilters, class "button-primary" ]
            else
                [ class "button-disabled" ]
    in
        button attributes
            [ text "Use"
            , i [ class "icon-filter" ] []
            ]


clearButton : Filters -> Html Msg
clearButton filters =
    let
        attributes =
            if filters.active then
                [ onClick ClearFilters ]
            else
                [ class "button-disabled" ]
    in
        button attributes
            [ text "Clear"
            , i [ class "icon-cancel" ] []
            ]
