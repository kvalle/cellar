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
    , error : Maybe String
    }


newInput : NewBeerForm -> (NewBeerForm -> NewBeerInput) -> String -> (String -> Result String String) -> NewBeerInput
newInput form getter value validateFn =
    let
        old =
            getter form

        validated =
            validateFn value
    in
        case validated of
            Ok _ ->
                { old | value = value, error = Nothing }

            Err err ->
                { old | value = value, error = Just err }


validateString : String -> Result String String
validateString val =
    Ok val


validateYear : String -> Result String String
validateYear val =
    Ok val


setInput : AddBeerInput -> NewBeerForm -> NewBeerForm
setInput input form =
    case input of
        BreweryInput value ->
            { form | brewery = (newInput form .brewery value validateString) }

        NameInput value ->
            { form | name = (newInput form .name value validateString) }

        StyleInput value ->
            { form | brewery = (newInput form .style value validateString) }

        YearInput value ->
            { form | year = (newInput form .year value validateYear) }


empty : NewBeerForm
empty =
    NewBeerForm
        (NewBeerInput "" Nothing)
        (NewBeerInput "" Nothing)
        (NewBeerInput "" Nothing)
        (NewBeerInput "" Nothing)
        False
        Nothing


setError : NewBeerForm -> Maybe String -> NewBeerForm
setError form error =
    { form | error = error }


validate : NewBeerForm -> Result String Beer
validate model =
    let
        yearResult =
            String.toInt model.year.value

        allFilledOut =
            not <| List.any String.isEmpty <| List.map .value [ model.name, model.year, model.style, model.brewery ]
    in
        case ( yearResult, allFilledOut ) of
            ( Ok year, True ) ->
                Ok <| Beer Nothing model.brewery.value model.name.value model.style.value year 1

            ( _, False ) ->
                Err "All fields must be filled out"

            ( Err err, _ ) ->
                Err <| "Input '" ++ model.year.value ++ "' is not a vaild year"
