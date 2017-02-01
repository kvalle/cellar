module Model.BeerForm exposing (BeerInput(..), withInput, isValid)

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
                    Just
                        { beer
                            | year =
                                case String.toInt year of
                                    Err _ ->
                                        beer.year

                                    Ok val ->
                                        val
                        }

                CountInput count ->
                    Just
                        { beer
                            | count =
                                case String.toInt count of
                                    Err _ ->
                                        beer.count

                                    Ok val ->
                                        val
                        }


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
