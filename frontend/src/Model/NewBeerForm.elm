module Model.NewBeerForm exposing (..)

import Model.Beer exposing (Beer)


type AddBeerInput
    = BreweryInput String
    | NameInput String
    | StyleInput String
    | YearInput String


type alias NewBeerInput =
    { value : String
    , error : Maybe String
    }


type alias NewBeerForm =
    { brewery : NewBeerInput
    , name : NewBeerInput
    , style : NewBeerInput
    , year : NewBeerInput
    , submitted : Bool
    , collapsed : Bool
    }


newInput : String -> (String -> Result String String) -> NewBeerInput
newInput value validateFn =
    case validateFn value of
        Ok _ ->
            { value = value, error = Nothing }

        Err err ->
            { value = value, error = Just err }


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


setInput : AddBeerInput -> NewBeerForm -> NewBeerForm
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


markAsSubmitted : NewBeerForm -> NewBeerForm
markAsSubmitted form =
    { form | submitted = True }


toggleCollapsed : NewBeerForm -> NewBeerForm
toggleCollapsed form =
    { form | collapsed = not form.collapsed }


empty : NewBeerForm
empty =
    NewBeerForm
        (newInput "" validateNotEmpty)
        (newInput "" validateNotEmpty)
        (newInput "" validateNotEmpty)
        (newInput "" validateYear)
        False
        True


validate : NewBeerForm -> Maybe Beer
validate model =
    case String.toInt model.year.value of
        Ok year ->
            Just <| Beer Nothing model.brewery.value model.name.value model.style.value year 1

        Err err ->
            Nothing
