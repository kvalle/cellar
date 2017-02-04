module Model.BeerForm exposing (BeerForm, empty, init, from, withInput, isValid, showInt, showMaybeString)

import Messages.BeerForm exposing (Field(..))
import Model.Beer exposing (Beer)


type alias BeerForm =
    { data : Beer
    }


from : Beer -> BeerForm
from beer =
    { data = beer }


init : BeerForm
init =
    from Model.Beer.empty


empty : BeerForm
empty =
    init


withInput : Field -> String -> BeerForm -> BeerForm
withInput field input form =
    let
        beer =
            form.data

        updatedBeer =
            case field of
                Brewery ->
                    { beer | brewery = input }

                Name ->
                    { beer | name = input }

                Style ->
                    { beer | style = input }

                Year ->
                    { beer | year = toIntWithDefault input beer.year }

                Count ->
                    { beer | count = toIntWithDefault input beer.count }

                Location ->
                    { beer | location = toMaybeString input beer.location }

                Shelf ->
                    { beer | shelf = toMaybeString input beer.shelf }
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


toIntWithDefault : String -> Int -> Int
toIntWithDefault str default =
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
