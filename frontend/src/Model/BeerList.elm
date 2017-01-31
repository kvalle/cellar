module Model.BeerList exposing (filtered, decrement, increment, delete, add)

import Model.Filter exposing (Filters)
import Model.Beer exposing (Beer)


filtered : Filters -> List Beer -> List Beer
filtered filters beers =
    List.filter (\beer -> Model.Filter.matches beer filters) beers


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
