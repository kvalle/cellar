module View.BeerList exposing (viewBeerList)

import Messages exposing (Msg(..))
import Model.Beer as Beer exposing (Beer)
import Model.Filter exposing (Filters)
import Update.Beer exposing (filteredBeers)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


viewBeerList : Filters -> List Beer -> Html Msg
viewBeerList filters beers =
    let
        heading =
            tr [] <| List.map (\name -> th [] [ text name ]) [ "#", "Brewery", "Beer", "Style", "" ]

        rows =
            List.map viewBeerRow <| filteredBeers filters beers
    in
        table [] <| heading :: rows


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
                [ viewIncrementCountAction beer
                , viewDecrementCountAction beer
                ]
            ]


viewIncrementCountAction : Beer -> Html Msg
viewIncrementCountAction beer =
    i [ onClick (IncrementBeerCount beer), class "action icon-plus" ] []


viewDecrementCountAction : Beer -> Html Msg
viewDecrementCountAction beer =
    if beer.count < 1 then
        i [ class "action icon-minus disabled" ] []
    else
        i [ onClick (DecrementBeerCount beer), class "action icon-minus" ] []
