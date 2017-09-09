module Data.BeerList exposing (addOrUpdate)

import Data.Beer exposing (Beer)


addOrUpdate : Beer -> List Beer -> List Beer
addOrUpdate beer beers =
    case beer.id of
        Nothing ->
            { beer | id = Just <| nextAvailableId beers } :: beers

        Just _ ->
            updateBeer (\_ -> beer) beer beers



-- Helper functions


nextAvailableId : List Beer -> Int
nextAvailableId beers =
    case List.filterMap .id beers |> List.maximum of
        Nothing ->
            1

        Just n ->
            n + 1


updateBeer : (Beer -> Beer) -> Beer -> List Beer -> List Beer
updateBeer fn original beers =
    let
        update beer =
            if beer.id == original.id then
                fn beer
            else
                beer
    in
        List.map update beers
