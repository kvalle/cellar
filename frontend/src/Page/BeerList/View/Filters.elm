module Page.BeerList.View.Filters exposing (viewFilters)

import Page.BeerList.Messages exposing (Msg(..))
import Page.BeerList.Model exposing (Model)
import Page.BeerList.Model.Filters exposing (Filters, FilterValue(..))
import Data.Beer exposing (Beer)
import Page.BeerList.Model.State exposing (DisplayState(..))
import Page.BeerList.Model.KeyEvent exposing (keys)
import Page.BeerList.View.HtmlExtra exposing (onKeyWithOptions, onKey)
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
                , div
                    [ class "filter-form"
                    , onKey keys.enter HideFilters
                    ]
                    [ textFilter model.filters
                    , yearMaxFilter model.filters model.beers
                    , styleFilter model.filters model.beers
                    , countMinFilter model.filters model.beers
                    , locationsFilter model.filters model.beers
                    , buttons model.filters
                    ]
                ]


textFilter : Filters -> Html Msg
textFilter filters =
    div []
        [ label [ for "text-filter-input" ] [ text "Matching text" ]
        , input
            [ type_ "search"
            , id "text-filter-input"
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


locationsFilter : Filters -> List Beer -> Html Msg
locationsFilter filters beers =
    div []
        [ label [ for "locations-filter-input" ] [ text "Stored at" ]
        , MultiSelect.multiSelect
            (let
                options =
                    MultiSelect.defaultOptions <| UpdateFilters << Locations

                toText location count =
                    location ++ " (" ++ toString count ++ ")"

                toItem ( count, location ) =
                    { value = location, text = toText location count, enabled = True }

                locations =
                    beers
                        |> List.map .location
                        |> List.filterMap identity
                        |> List.sort
                        |> List.Extra.group
                        |> List.map (\xs -> ( List.length xs, Maybe.withDefault "" (List.head xs) ))
             in
                { options | items = List.map toItem locations }
            )
            [ class "u-full-width" ]
            filters.locations
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
                [ onClick HideFilters, class "button-primary" ]
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
