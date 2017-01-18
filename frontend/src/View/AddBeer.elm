module View.AddBeer exposing (viewAddBeerForm)

import Messages exposing (Msg(..))
import Model.NewBeerForm exposing (NewBeerForm, NewBeerInput, AddBeerInput(..))
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


viewError : Bool -> Maybe String -> Html Msg
viewError submitted error =
    div [ class "error" ] <|
        case ( submitted, error ) of
            ( True, Just errorText ) ->
                [ text errorText ]

            _ ->
                [ text "" ]


textInputWithLabel : String -> String -> (String -> Msg) -> Bool -> NewBeerInput -> Html Msg
textInputWithLabel labelText tag msg submitted beerInput =
    div []
        [ label [ for <| tag ++ "-input" ]
            [ text labelText ]
        , input
            [ type_ "text"
            , class "u-full-width"
            , id <| tag ++ "-input"
            , onInput msg
            , value beerInput.value
            , onEnter AddNewBeer
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


viewAddBeerForm : NewBeerForm -> Html Msg
viewAddBeerForm model =
    div [ class "add-beer-form" ]
        [ h2 [] [ text "Add beer" ]
        , textInputWithLabel "Brewery" "brewery" (\val -> UpdateInput (BreweryInput val)) model.submitted model.brewery
        , textInputWithLabel "Beer Name" "name" (\val -> UpdateInput (NameInput val)) model.submitted model.name
        , textInputWithLabel "Beer Style" "style" (\val -> UpdateInput (StyleInput val)) model.submitted model.style
        , textInputWithLabel "Production year" "year" (\val -> UpdateInput (YearInput val)) model.submitted model.year
        , br [] []
        , div []
            [ buttonWithIcon "Add" "beer" AddNewBeer "button-primary"
            , buttonWithIcon "Clear" "cancel" ClearNewBeerForm ""
            ]
        ]
