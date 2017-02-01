module Model.BeerForm exposing (BeerInput(..), withInput, isValid, showInt)

import Model.Beer exposing (Beer)


type BeerInput
    = BreweryInput String
    | NameInput String
    | StyleInput String
    | YearInput String
    | CountInput String


withInput : BeerInput -> Maybe Beer -> Maybe Beer
withInput input maybeBeer =
    case maybeBeer of
        Nothing ->
            Nothing

        Just beer ->
            case input of
                BreweryInput brewery ->
                    Just { beer | brewery = brewery }

                NameInput name ->
                    Just { beer | name = name }

                StyleInput style ->
                    Just { beer | style = style }

                YearInput year ->
                    Just { beer | year = toInt year beer.year }

                CountInput count ->
                    Just { beer | count = toInt count beer.count }


showInt : Int -> String
showInt num =
    if num == 0 then
        ""
    else
        toString num


toInt : String -> Int -> Int
toInt str default =
    if str == "" then
        0
    else
        String.toInt str |> Result.withDefault default


isValid : Beer -> Bool
isValid beer =
    let
        notEmpty =
            not << String.isEmpty
    in
        notEmpty beer.brewery
            && notEmpty beer.name
            && notEmpty beer.style
            && (beer.year > 0)
            && (beer.count > 0)
