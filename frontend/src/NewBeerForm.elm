module NewBeerForm exposing (..)

import Beer exposing (Beer)


type alias NewBeerForm =
    { brewery : String
    , name : String
    , style : String
    , year : String
    , error : Maybe String
    }


empty : NewBeerForm
empty =
    NewBeerForm "" "" "" "" Nothing


updateError : NewBeerForm -> Maybe String -> NewBeerForm
updateError form error =
    { form | error = error }


updateBrewery : NewBeerForm -> String -> NewBeerForm
updateBrewery form brewery =
    { form | brewery = brewery }


updateName : NewBeerForm -> String -> NewBeerForm
updateName form name =
    { form | name = name }


updateYear : NewBeerForm -> String -> NewBeerForm
updateYear form year =
    { form | year = year }


updateStyle : NewBeerForm -> String -> NewBeerForm
updateStyle form style =
    { form | style = style }


validate : NewBeerForm -> Result String Beer
validate model =
    let
        yearResult =
            String.toInt model.year

        allFilledOut =
            not <| List.any String.isEmpty [ model.name, model.year, model.style, model.brewery ]
    in
        case ( yearResult, allFilledOut ) of
            ( Ok year, True ) ->
                Ok <| Beer Nothing model.brewery model.name model.style year 1

            ( _, False ) ->
                Err "All fields must be filled out"

            ( Err err, _ ) ->
                Err <| "Input '" ++ model.year ++ "' is not a vaild year"
