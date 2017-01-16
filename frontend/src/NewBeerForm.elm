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
updateError model error =
    { model | error = error }


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

            ( Err err, _ ) ->
                Err err

            ( Ok _, False ) ->
                Err "All fields must be filled out"
