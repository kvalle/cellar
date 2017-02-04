module Model.BeerForm exposing (BeerForm, empty, init, from, withInput, isValid, showInt, showMaybeString)

import Messages.BeerForm exposing (BeerInput(..))
import Model.Beer exposing (Beer)


type alias BeerForm =
    { data : Beer
    }


type CcompleteField
    = Brewery


type CompleteMsg
    = SelectValue String
    | SetAutocompleteState Autocomplete.Msg


from : Beer -> BeerForm
from beer =
    { data = beer
    }


init : BeerForm
init =
    from Model.Beer.empty


empty : BeerForm
empty =
    init


withInput : BeerInput -> BeerForm -> BeerForm
withInput input form =
    let
        beer =
            form.data

        updatedBeer =
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
    in
        { form | data = updatedBeer }


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
