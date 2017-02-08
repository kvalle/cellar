module View.BeerList exposing (viewBeerList)

import Messages exposing (Msg(..))
import Model exposing (Model)
import Model.Beer exposing (Beer)
import Model.BeerList as BeerList
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value, colspan, title)
import Html.Events exposing (onClick, onInput)
import Table


viewBeerList : Model -> Html Msg
viewBeerList model =
    if model.beers |> not << List.isEmpty then
        let
            filteredBeers =
                BeerList.filtered model.filters model.beers
        in
            Table.view
                (tableConfig ( List.length filteredBeers, List.length model.beers ))
                model.tableState
                filteredBeers
    else if model.state.error == Nothing then
        viewEmptyMessage
    else
        text ""


tableConfig : ( Int, Int ) -> Table.Config Beer Msg
tableConfig showCount =
    let
        default =
            Table.defaultCustomizations
    in
        Table.customConfig
            { toId = .id >> (Maybe.withDefault 0) >> toString
            , toMsg = SetTableState
            , columns =
                [ intColumnWithClasses "count" "#" .count
                , stringColumnWithClasses "brewery" "Brewery" .brewery
                , stringColumnWithClasses "name" "Name" .name
                , floatColumnWithClasses "vol" "Vol" .volume
                , intColumnWithClasses "year" "Year" .year
                , stringColumnWithClasses "style" "Style" .style
                , stringColumnWithClasses "location" "Location" (.location >> Maybe.withDefault "")
                , stringColumnWithClasses "shelf" "Shelf" (.shelf >> Maybe.withDefault "")
                , actionColumn
                ]
            , customizations =
                { default
                    | tableAttrs = [ class "beer-list" ]
                    , rowAttrs = beerRowAttributes
                    , tfoot = tableFooter showCount
                }
            }


columnWithClasses : String -> String -> (a -> comparable) -> (a -> String) -> Table.Column a Msg
columnWithClasses classes name asComparable asString =
    Table.veryCustomColumn
        { name = name
        , viewData =
            \a ->
                Table.HtmlDetails
                    [ class classes ]
                    [ (text << asString) a ]
        , sorter = Table.decreasingOrIncreasingBy asComparable
        }


stringColumnWithClasses : String -> String -> (a -> String) -> Table.Column a Msg
stringColumnWithClasses classes name asString =
    columnWithClasses classes name asString asString


intColumnWithClasses : String -> String -> (a -> Int) -> Table.Column a Msg
intColumnWithClasses classes name asInt =
    columnWithClasses classes name asInt (toString << asInt)


floatColumnWithClasses : String -> String -> (a -> Float) -> Table.Column a Msg
floatColumnWithClasses classes name asFloat =
    columnWithClasses classes name asFloat (toString << asFloat)


actionColumn : Table.Column Beer Msg
actionColumn =
    Table.veryCustomColumn
        { name = ""
        , viewData =
            \beer ->
                Table.HtmlDetails [ class "actions" ]
                    [ viewIncrementAction beer
                    , viewDecrementAction beer
                    , viewDeleteAction beer
                    , viewEditAction beer
                    ]
        , sorter = Table.unsortable
        }


beerRowAttributes : Beer -> List (Attribute msg)
beerRowAttributes beer =
    [ class <|
        if beer.count < 1 then
            "zero-row"
        else
            ""
    ]


viewEmptyMessage : Html Msg
viewEmptyMessage =
    span [ class "empty-beer-list" ]
        [ text "Your cellar appears to be empty. Try "
        , span [ onClick <| ShowForm Model.Beer.empty, class "action" ] [ text "adding" ]
        , text " a few beers!"
        ]


viewIncrementAction : Beer -> Html Msg
viewIncrementAction beer =
    i [ onClick (IncrementBeer beer), class "action icon-plus", title "Add 1" ] []


viewDecrementAction : Beer -> Html Msg
viewDecrementAction beer =
    if beer.count < 1 then
        i [ class "action icon-minus disabled" ] []
    else
        i [ onClick (DecrementBeer beer), class "action icon-minus", title "Remove 1" ] []


viewDeleteAction : Beer -> Html Msg
viewDeleteAction beer =
    i [ onClick (DeleteBeer beer), class "action icon-trash", title "Delete" ] []


viewEditAction : Beer -> Html Msg
viewEditAction beer =
    i [ onClick (ShowForm beer), class "action icon-pencil", title "Edit" ] []


tableFooter : ( Int, Int ) -> Maybe (Table.HtmlDetails msg)
tableFooter ( showing, total ) =
    if showing == total then
        Nothing
    else
        let
            message =
                if showing == 0 then
                    "All beers are hidden by filters…"
                else
                    "Filter active, showing "
                        ++ (toString showing)
                        ++ " of "
                        ++ (toString total)
                        ++ " beers"
        in
            Just <|
                Table.HtmlDetails
                    [ class "filtered-beer-list" ]
                    [ tr []
                        [ td [ colspan 6 ] [ text message ] ]
                    ]
