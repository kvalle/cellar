module View.BeerList exposing (viewBeerList)

import Messages exposing (Msg(..))
import Model.Beer exposing (Beer)
import Model.Filter exposing (Filters)
import Model.Tab as Tab
import Update.Beer as Beer
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value, colspan)
import Html.Events exposing (onClick, onInput)
import Table


viewBeerList : Filters -> List Beer -> Table.State -> Html Msg
viewBeerList filters beers tableState =
    let
        filteredBeers =
            Beer.filtered filters beers

        rows =
            if List.isEmpty beers then
                [ viewEmptyTableRow ]
            else
                List.map viewBeerRow filteredBeers
    in
        Table.view tableConfig tableState filteredBeers



-- UNEXPOSED FUNCTIONS


tableConfig : Table.Config Beer Msg
tableConfig =
    Table.config
        { -- FIXME: Should be .id not .name
          toId = .name
        , toMsg = SetTableState
        , columns =
            [ Table.intColumn "#" .count
            , Table.stringColumn "Brewery" .brewery
            , Table.stringColumn "Name" .name
            , Table.intColumn "Year" .year
            , Table.stringColumn "Style" .style
            ]
        }


viewEmptyTableRow : Html Msg
viewEmptyTableRow =
    tr [ class "empty-beer-list" ]
        [ td [ colspan 5 ]
            [ text "Your cellar appears to be empty. Try "
            , span [ onClick (ChangeTab Tab.AddBeerTab), class "action" ] [ text "adding" ]
            , text " a few beers!"
            ]
        ]


viewBeerRow : Beer -> Html Msg
viewBeerRow beer =
    let
        trClass =
            if beer.count < 1 then
                "zero-row"
            else
                ""
    in
        tr
            [ class trClass ]
            [ td [ class "beer-count" ] [ text <| toString beer.count ]
            , td [] [ text beer.brewery ]
            , td []
                [ text beer.name
                , span [ class "beer-year" ] [ text <| "(" ++ (toString beer.year) ++ ")" ]
                ]
            , td [ class "beer-style" ] [ text beer.style ]
            , td []
                [ viewIncrementAction beer
                , viewDecrementAction beer
                , viewDeleteAction beer
                ]
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
