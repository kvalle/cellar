module View.BeerList exposing (viewBeerList)

import Messages exposing (Msg(..))
import Model.Beer exposing (Beer)
import Model.Filter exposing (Filters)
import Model.Tab as Tab
import Model.BeerList as BeerList
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value, colspan)
import Html.Events exposing (onClick, onInput)
import Table


viewBeerList : Filters -> List Beer -> Table.State -> Html Msg
viewBeerList filters beers tableState =
    if List.isEmpty beers then
        viewEmptyMessage
    else
        beers |> BeerList.filtered filters |> Table.view tableConfig tableState


tableConfig : Table.Config Beer Msg
tableConfig =
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
                , actionColumn
                ]
            , customizations =
                { default
                    | tableAttrs = [ class "beer-list" ]
                    , rowAttrs = beerRowAttributes
                }
            }


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
        , span [ onClick (ChangeTab Tab.AddBeerTab), class "action" ] [ text "adding" ]
        , text " a few beers!"
        ]


viewIncrementAction : Beer -> Html Msg
viewIncrementAction beer =
    i [ onClick (IncrementBeer beer), class "action icon-plus" ] []


viewDecrementAction : Beer -> Html Msg
viewDecrementAction beer =
    if beer.count < 1 then
        i [ class "action icon-minus disabled" ] []
    else
        i [ onClick (DecrementBeer beer), class "action icon-minus" ] []


viewDeleteAction : Beer -> Html Msg
viewDeleteAction beer =
    i [ onClick (DeleteBeer beer), class "action icon-trash" ] []
