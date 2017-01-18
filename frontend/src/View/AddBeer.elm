module View.AddBeer exposing (viewAddBeerForm)

import Messages exposing (Msg(..))
import Model.NewBeerForm exposing (NewBeerForm, AddBeerInput(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg
            else
                Json.Decode.fail "not ENTER"
    in
        on "keydown" (Json.Decode.andThen isEnter keyCode)


textInputWithLabel : String -> String -> (String -> Msg) -> String -> String -> Html Msg
textInputWithLabel labelText tag msg inputValue placeholderText =
    div []
        [ label [ for <| tag ++ "-input" ] [ text labelText ]
        , input
            [ type_ "text"
            , placeholder placeholderText
            , class "u-full-width"
            , id <| tag ++ "-input"
            , onInput msg
            , value inputValue
            , onEnter AddNewBeer
            ]
            []
        ]


buttonWithIcon : String -> String -> msg -> String -> Html msg
buttonWithIcon buttonText icon msg classes =
    button [ onClick msg, class classes ]
        [ text buttonText
        , i [ class <| "icon-" ++ icon ] []
        ]


viewAddBeerForm : NewBeerForm -> Html Msg
viewAddBeerForm model =
    div []
        [ h2 [] [ text "Add beer" ]
        , textInputWithLabel "Brewery" "brewery" (\val -> UpdateInput (BreweryInput val)) model.brewery.value "updateInput Brewing"
        , textInputWithLabel "Beer Name" "name" (\val -> UpdateInput (NameInput val)) model.name.value "Baz Pils"
        , textInputWithLabel "Beer Style" "style" (\val -> UpdateInput (StyleInput val)) model.style.value "Pilsner"
        , textInputWithLabel "Production year" "year" (\val -> UpdateInput (YearInput val)) model.year.value "2017"
        , div []
            [ buttonWithIcon "Add" "beer" AddNewBeer "button-primary"
            , buttonWithIcon "Clear" "cancel" ClearNewBeerForm ""
            ]
        , div [ class "errors" ] <|
            case model.error of
                Nothing ->
                    []

                Just error ->
                    [ text error ]
        ]
