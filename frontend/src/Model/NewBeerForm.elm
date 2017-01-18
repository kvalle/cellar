module Model.NewBeerForm exposing (..)

import Model.Beer exposing (Beer)


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


setBrewery : NewBeerForm -> String -> NewBeerForm
setBrewery form brewery =
    let
        old =
            form.brewery

        newInput =
            { old | value = brewery }
    in
        { form | brewery = newInput }


setName : NewBeerForm -> String -> NewBeerForm
setName form name =
    let
        old =
            form.name

        newInput =
            { old | value = name }
    in
        { form | name = newInput }


setYear : NewBeerForm -> String -> NewBeerForm
setYear form year =
    let
        old =
            form.year

        newInput =
            { old | value = year }
    in
        { form | year = newInput }


setStyle : NewBeerForm -> String -> NewBeerForm
setStyle form style =
    let
        old =
            form.style

        newInput =
            { old | value = style }
    in
        { form | style = newInput }


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
