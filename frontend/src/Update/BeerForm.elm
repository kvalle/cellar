module Update.BeerForm exposing (empty, markSubmitted, setInput, toBeer)

import Model.BeerForm exposing (BeerForm, BeerInput(..), BeerFormField)
import Model.Beer exposing (Beer)


empty : BeerForm
empty =
    BeerForm
        (newInput "" validateNotEmpty)
        (newInput "" validateNotEmpty)
        (newInput "" validateNotEmpty)
        (newInput "" validateYear)
        False


toBeer : BeerForm -> Maybe Beer
toBeer form =
    let
        inputsValidated =
            List.filterMap .error [ form.brewery, form.name, form.style, form.year ] |> List.isEmpty

        year =
            String.toInt form.year.value
    in
        case ( inputsValidated, year ) of
            ( True, Ok year ) ->
                Just <| Beer Nothing form.brewery.value form.name.value form.style.value year 1

            _ ->
                Nothing


markSubmitted : BeerForm -> BeerForm
markSubmitted form =
    { form | submitted = True }


setInput : BeerInput -> BeerForm -> BeerForm
setInput input form =
    case input of
        BreweryInput value ->
            { form | brewery = (newInput value validateNotEmpty) }

        NameInput value ->
            { form | name = (newInput value validateNotEmpty) }

        StyleInput value ->
            { form | style = (newInput value validateNotEmpty) }

        YearInput value ->
            { form | year = (newInput value validateYear) }



-- UNEXPOSED FUNCTIONS


validateNotEmpty : String -> Result String String
validateNotEmpty val =
    case String.isEmpty val of
        True ->
            Err "Cannot be empty"

        False ->
            Ok val


validateYear : String -> Result String String
validateYear val =
    case String.toInt val of
        Err _ ->
            Err "Not a valid year"

        Ok _ ->
            Ok val


newInput : String -> (String -> Result String String) -> BeerFormField
newInput value validateFn =
    case validateFn value of
        Ok _ ->
            { value = value, error = Nothing }

        Err err ->
            { value = value, error = Just err }
