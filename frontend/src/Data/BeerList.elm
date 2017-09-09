module Data.BeerList exposing (addOrUpdate, getById, nextAvailableId, delete)

import Data.Beer exposing (Beer)


addOrUpdate : Beer -> List Beer -> List Beer
addOrUpdate beer beers =
    case getById beer.id beers of
        Nothing ->
            beer :: beers

        Just _ ->
            updateBeer (\_ -> beer) beer beers


getById : Int -> List Beer -> Maybe Beer
getById beerId beerList =
    case List.filter (.id >> (==) beerId) beerList of
        [ beer ] ->
            Just beer

        _ ->
            Nothing


delete : Beer -> List Beer -> List Beer
delete beer =
    List.filter (\b -> b.id /= beer.id)


nextAvailableId : List Beer -> Int
nextAvailableId beers =
    case List.map .id beers |> List.maximum of
        Nothing ->
            1

        Just n ->
            n + 1



-- Helper functions


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
