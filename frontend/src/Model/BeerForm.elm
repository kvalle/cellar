module Model.BeerForm exposing (BeerForm, BeerInput(..), init, withInput, isValid, showInt, showMaybeString)

import Model.Beer exposing (Beer)


type alias BeerForm =
    Beer


type BeerInput
    = BreweryInput String
    | NameInput String
    | StyleInput String
    | YearInput String
    | CountInput String
    | LocationInput String
    | ShelfInput String


init : BeerForm
init =
    Model.Beer.empty


withInput : BeerInput -> BeerForm -> BeerForm
withInput input beer =
    case input of
        BreweryInput brewery ->
            { beer | brewery = brewery }

        NameInput name ->
            { beer | name = name }

        StyleInput style ->
            { beer | style = style }

        YearInput year ->
            { beer | year = toInt year beer.year }

        CountInput count ->
            { beer | count = toInt count beer.count }

        LocationInput location ->
            { beer | location = toMaybeString location beer.location }

        ShelfInput shelf ->
            { beer | shelf = toMaybeString shelf beer.shelf }


showInt : Int -> String
showInt num =
    if num == 0 then
        ""
    else
        toString num


showMaybeString : Maybe String -> String
showMaybeString optional =
    optional |> Maybe.withDefault ""


toInt : String -> Int -> Int
toInt str default =
    if str == "" then
        0
    else
        String.toInt str |> Result.withDefault default


toMaybeString : String -> Maybe String -> Maybe String
toMaybeString str default =
    if str == "" then
        Nothing
    else
        Just str


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
