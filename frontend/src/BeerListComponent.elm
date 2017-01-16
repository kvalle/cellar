module BeerListComponent exposing (..)

import Messages exposing (..)
import Beer exposing (Beer)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


-- MODEL


empty : List Beer
empty =
    []



-- UPDATE


update : BeerListMsg -> List Beer -> List Beer
update msg model =
    case msg of
        DecrementBeerCount beer ->
            Beer.decrementBeerCount beer model

        IncrementBeerCount beer ->
            Beer.incrementBeerCount beer model

        AddBeerToList beer ->
            Beer.addBeer beer model



-- VIEW


viewBeerTable : String -> List Beer -> Html BeerListMsg
viewBeerTable filter beers =
    let
        heading =
            tr [] <| List.map (\name -> th [] [ text name ]) [ "#", "Brewery", "Beer", "Style", "" ]

        rows =
            List.map viewBeerRow <| Beer.filteredBeers filter beers
    in
        table [] <| heading :: rows


viewBeerRow : Beer -> Html BeerListMsg
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


viewIncrementCountAction : Beer -> Html BeerListMsg
viewIncrementCountAction beer =
    i [ onClick (IncrementBeerCount beer), class "action icon-plus" ] []


viewDecrementCountAction : Beer -> Html BeerListMsg
viewDecrementCountAction beer =
    if beer.count < 1 then
        i [ class "action icon-minus disabled" ] []
    else
        i [ onClick (DecrementBeerCount beer), class "action icon-minus" ] []
