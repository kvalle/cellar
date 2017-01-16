module AddBeerComponent exposing (..)

import Messages exposing (..)
import Beer exposing (Beer)
import NewBeerForm exposing (NewBeerForm)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


-- MODEL


updateError : NewBeerForm -> Maybe String -> NewBeerForm
updateError model error =
    { model | error = error }


validateForm : NewBeerForm -> Result String Beer
validateForm model =
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



-- UPDATE


update : AddBeerMsg -> NewBeerForm -> NewBeerForm
update msg model =
    case msg of
        UpdateBrewery brewery ->
            { model | brewery = brewery }

        UpdateName name ->
            { model | name = name }

        UpdateYear year ->
            { model | year = year }

        UpdateStyle style ->
            { model | style = style }

        ClearForm ->
            NewBeerForm.empty

        AddNewBeer ->
            -- handled by Main for now
            model



-- VIEW


viewAddBeerForm : NewBeerForm -> Html AddBeerMsg
viewAddBeerForm model =
    div []
        [ h2 [] [ text "Add beer" ]
        , input [ type_ "text", placeholder "brewery", onInput UpdateBrewery, value model.brewery ] []
        , input [ type_ "text", placeholder "name", onInput UpdateName, value model.name ] []
        , input [ type_ "text", placeholder "year", onInput UpdateYear, value model.year ] []
        , input [ type_ "text", placeholder "style", onInput UpdateStyle, value model.style ] []
        , button [ onClick AddNewBeer ]
            [ i [ class "icon-beer" ] []
            , text "Add"
            ]
        , span [ class "errors" ] <|
            case model.error of
                Nothing ->
                    []

                Just error ->
                    [ text error ]
        ]
