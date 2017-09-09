module Page.BeerList.Model.BeerList exposing (BeerList, init, filtered, decrement, increment, delete)

import Page.BeerList.Model.Filters exposing (Filters)
import Data.Beer exposing (Beer)


{--
  Module deprecated, use Data.BeerList instead
--}


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



-- UNEXPOSED FUNCTIONS


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
