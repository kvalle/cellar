module Update.Beer exposing (filteredBeers, decrementBeerCount, incrementBeerCount, addBeer)

import Model.Filter exposing (Filters)
import Model.Beer exposing (Beer)


filteredBeers : Filters -> List Beer -> List Beer
filteredBeers filters beers =
    List.filter (isMatch filters) beers


decrementBeerCount : Beer -> List Beer -> List Beer
decrementBeerCount =
    updateBeer (\beer -> { beer | count = beer.count - 1 })


incrementBeerCount : Beer -> List Beer -> List Beer
incrementBeerCount =
    updateBeer (\beer -> { beer | count = beer.count + 1 })


addBeer : Beer -> List Beer -> List Beer
addBeer beer beers =
    { beer | id = Just <| nextAvailableId beers } :: beers



-- UNEXPOSED FUNCTIONS


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


isMatch : Filters -> Beer -> Bool
isMatch filters beer =
    let
        textMatch string =
            String.contains (String.toLower filters.textMatch) (String.toLower string)

        isTextMatch =
            textMatch beer.name || textMatch beer.brewery || textMatch beer.style || textMatch (toString beer.year)

        isInYearRange =
            beer.year <= filters.olderThan
    in
        isTextMatch && isInYearRange
