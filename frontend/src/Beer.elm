module Beer exposing (Beer, filteredBeers, decrementBeerCount, incrementBeerCount, addBeer)


type alias Beer =
    { id : Maybe Int
    , brewery : String
    , name : String
    , style : String
    , year : Int
    , count : Int
    }


filteredBeers : String -> List Beer -> List Beer
filteredBeers filter beers =
    let
        isMatch string =
            String.contains (String.toLower filter) (String.toLower string)

        beerMatches beer =
            isMatch beer.name || isMatch beer.brewery || isMatch beer.style || isMatch (toString beer.year)
    in
        List.filter beerMatches beers


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
