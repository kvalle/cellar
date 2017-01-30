module Update.Beer exposing (filtered, decrement, increment, delete, add)

import Model.Filter exposing (Filters)
import Model.Beer exposing (Beer)


filtered : Filters -> List Beer -> List Beer
filtered filters beers =
    List.filter (matches filters) beers


decrement : Beer -> List Beer -> List Beer
decrement =
    updateBeer (\beer -> { beer | count = beer.count - 1 })


increment : Beer -> List Beer -> List Beer
increment =
    updateBeer (\beer -> { beer | count = beer.count + 1 })


delete : Beer -> List Beer -> List Beer
delete beer =
    List.filter (\b -> b.id /= beer.id)


add : Beer -> List Beer -> List Beer
add beer beers =
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


matches : Filters -> Beer -> Bool
matches filters beer =
    let
        textMatch string =
            String.contains (String.toLower filters.textMatch) (String.toLower string)

        matchesText =
            textMatch beer.name || textMatch beer.brewery || textMatch beer.style || textMatch (toString beer.year)

        isInYearRange =
            beer.year <= filters.olderThan

        matchesStyles =
            List.isEmpty filters.styles || List.member beer.style filters.styles
    in
        matchesText && isInYearRange && matchesStyles
