module View.BeerList exposing (viewBeerList)

import Messages exposing (Msg(..))
import Model.Beer exposing (Beer)
import Model.Filters exposing (Filters)
import Model.BeerList as BeerList
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value, colspan, title)
import Html.Events exposing (onClick, onInput)
import Table


viewBeerList : Filters -> List Beer -> Table.State -> Html Msg
viewBeerList filters beers tableState =
    if List.isEmpty beers then
        viewEmptyMessage
    else
        let
            filteredBeers =
                BeerList.filtered filters beers
        in
            Table.view
                (tableConfig ( List.length filteredBeers, List.length beers ))
                tableState
                filteredBeers


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
                [ Table.intColumn "#" .count
                , Table.stringColumn "Brewery" .brewery
                , Table.stringColumn "Name" .name
                , Table.intColumn "Year" .year
                , Table.stringColumn "Style" .style
                , Table.stringColumn "Location" <| .location >> Maybe.withDefault ""
                , Table.stringColumn "Shelf" <| .shelf >> Maybe.withDefault ""
                , actionColumn
                ]
            , customizations =
                { default
                    | tableAttrs = [ class "beer-list" ]
                    , rowAttrs = beerRowAttributes
                    , tfoot = tableFooter showCount
                }
            }


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


actionColumn : Table.Column Beer Msg
actionColumn =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewActions
        , sorter = Table.unsortable
        }


viewActions : Beer -> Table.HtmlDetails Msg
viewActions beer =
    Table.HtmlDetails []
        [ viewIncrementAction beer
        , viewDecrementAction beer
        , viewDeleteAction beer
        , viewEditAction beer
        ]


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
        , span [ onClick ShowAddBeerForm, class "action" ] [ text "adding" ]
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
    i [ onClick (ShowEditBeerForm beer), class "action icon-pencil", title "Edit" ] []
