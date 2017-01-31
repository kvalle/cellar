module Model.BeerForm exposing (BeerForm, BeerFormField, BeerInput(..), init, empty, markSubmitted, setInput, toBeer)

import Model.Beer exposing (Beer)


type BeerInput
    = BreweryInput String
    | NameInput String
    | StyleInput String
    | YearInput String


type alias BeerFormField =
    { value : String
    , error : Maybe String
    }


type alias BeerForm =
    { brewery : BeerFormField
    , name : BeerFormField
    , style : BeerFormField
    , year : BeerFormField
    , submitted : Bool
    }


init : BeerForm
init =
    BeerForm
        { value = "", error = Nothing }
        { value = "", error = Nothing }
        { value = "", error = Nothing }
        { value = "", error = Nothing }
        False


empty : BeerForm
empty =
    init


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
