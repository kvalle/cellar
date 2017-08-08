module Page.BeerList.Model.BeerList exposing (BeerList, init, filtered, decrement, increment, delete, addOrUpdate)

import Page.BeerList.Model.Filters exposing (Filters)
import Data.Beer exposing (Beer)


type alias BeerList =
    List Beer


init : BeerList
init =
    []


filtered : Filters -> BeerList -> BeerList
filtered filters beers =
    List.filter (\beer -> Page.BeerList.Model.Filters.matches beer filters) beers


decrement : Beer -> BeerList -> BeerList
decrement =
    updateBeer (\beer -> { beer | count = beer.count - 1 })


increment : Beer -> BeerList -> BeerList
increment =
    updateBeer (\beer -> { beer | count = beer.count + 1 })


delete : Beer -> BeerList -> BeerList
delete beer =
    List.filter (\b -> b.id /= beer.id)


addOrUpdate : Beer -> BeerList -> BeerList
addOrUpdate beer beers =
    case beer.id of
        Nothing ->
            { beer | id = Just <| nextAvailableId beers } :: beers

        Just _ ->
            updateBeer (\_ -> beer) beer beers



-- UNEXPOSED FUNCTIONS


nextAvailableId : BeerList -> Int
nextAvailableId beers =
    case List.filterMap .id beers |> List.maximum of
        Nothing ->
            1

        Just n ->
            n + 1


updateBeer : (Beer -> Beer) -> Beer -> BeerList -> BeerList
updateBeer fn original beers =
    let
        update beer =
            if beer.id == original.id then
                fn beer
            else
                beer
    in
        List.map update beers
