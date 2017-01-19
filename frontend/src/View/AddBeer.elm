module View.AddBeer exposing (viewAddBeerForm)

import Messages exposing (Msg(..))
import Model.BeerForm exposing (BeerForm, BeerFormField, BeerInput(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import View exposing (onEnter)


viewAddBeerForm : BeerForm -> Html Msg
viewAddBeerForm model =
    div [ class "add-beer-form" ]
        [ fieldwithLabel "Brewery" "brewery" (\val -> UpdateBeerForm (BreweryInput val)) model.submitted model.brewery
        , fieldwithLabel "Beer Name" "name" (\val -> UpdateBeerForm (NameInput val)) model.submitted model.name
        , fieldwithLabel "Beer Style" "style" (\val -> UpdateBeerForm (StyleInput val)) model.submitted model.style
        , fieldwithLabel "Production year" "year" (\val -> UpdateBeerForm (YearInput val)) model.submitted model.year
        , br [] []
        , div []
            [ buttonWithIcon "Add" "beer" SubmitBeerForm "button-primary"
            , buttonWithIcon "Clear" "cancel" ClearBeerForm ""
            ]
        ]



-- UNEXPOSED FUNCTIONS


fieldwithLabel : String -> String -> (String -> Msg) -> Bool -> BeerFormField -> Html Msg
fieldwithLabel labelText tag msg submitted beerInput =
    div []
        [ label [ for <| tag ++ "-input" ]
            [ text labelText ]
        , input
            [ type_ "text"
            , class "u-full-width"
            , id <| tag ++ "-input"
            , onInput msg
            , value beerInput.value
            , onEnter SubmitBeerForm
            ]
            []
        , div [ class "error" ] <|
            case ( submitted, beerInput.error ) of
                ( True, Just errorText ) ->
                    [ text errorText ]

                _ ->
                    []
        ]


buttonWithIcon : String -> String -> msg -> String -> Html msg
buttonWithIcon buttonText icon msg classes =
    button [ onClick msg, class classes ]
        [ text buttonText
        , i [ class <| "icon-" ++ icon ] []
        ]
