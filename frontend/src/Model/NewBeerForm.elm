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


updateError : NewBeerForm -> Maybe String -> NewBeerForm
updateError form error =
    { form | error = error }


updateBrewery : NewBeerForm -> String -> NewBeerForm
updateBrewery form brewery =
    let
        old =
            form.brewery

        newInput =
            { old | value = brewery }
    in
        { form | brewery = newInput }


updateName : NewBeerForm -> String -> NewBeerForm
updateName form name =
    let
        old =
            form.name

        newInput =
            { old | value = name }
    in
        { form | name = newInput }


updateYear : NewBeerForm -> String -> NewBeerForm
updateYear form year =
    let
        old =
            form.year

        newInput =
            { old | value = year }
    in
        { form | year = newInput }


updateStyle : NewBeerForm -> String -> NewBeerForm
updateStyle form style =
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
