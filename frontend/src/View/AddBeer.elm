module View.AddBeer exposing (viewAddBeerForm)

import Messages exposing (Msg(..))
import Model.Beer exposing (Beer)
import Model.NewBeerForm exposing (NewBeerForm)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


textInputWithLabel : String -> String -> (String -> msg) -> String -> String -> Html msg
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
    Html.form [ onSubmit AddNewBeer ]
        [ h2 [] [ text "Add beer" ]
        , textInputWithLabel "Brewery" "brewery" UpdateBrewery model.brewery "Foobar Brewing"
        , textInputWithLabel "Beer Name" "name" UpdateName model.name "Baz Pils"
        , textInputWithLabel "Beer Style" "style" UpdateStyle model.style "Pilsner"
        , textInputWithLabel "Production year" "year" UpdateYear model.year "2017"
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
