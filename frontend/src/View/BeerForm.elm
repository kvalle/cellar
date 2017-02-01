module View.BeerForm exposing (viewBeerForm)

import Messages as Msg exposing (Msg)
import Model exposing (Model)
import Model.BeerForm exposing (BeerInput(..))
import Html exposing (..)
import Html.Events exposing (onClick, on, onWithOptions, onInput, defaultOptions, keyCode)
import Html.Attributes exposing (id, class, type_, for, src, title, value)
import Json.Decode


viewBeerForm : Model -> Html Msg
viewBeerForm model =
    case model.beerForm of
        Nothing ->
            text ""

        Just beer ->
            div [ class "beer-form-modal", onClick Msg.HideBeerForm ]
                [ div [ class "beer-form", onClickNoPropagation (Msg.ShowEditBeerForm beer) ]
                    [ h3 []
                        [ case beer.id of
                            Nothing ->
                                text "Add beer"

                            Just _ ->
                                text "Edit beer"
                        ]
                    , fieldwithLabel "Brewery" "brewery" (\val -> Msg.UpdateBeerForm (BreweryInput val)) beer.brewery
                    , fieldwithLabel "Beer Name" "name" (\val -> Msg.UpdateBeerForm (NameInput val)) beer.name
                    , fieldwithLabel "Beer Style" "style" (\val -> Msg.UpdateBeerForm (StyleInput val)) beer.style
                    , fieldwithLabel "Production year" "year" (\val -> Msg.UpdateBeerForm (YearInput val)) (Model.BeerForm.showInt beer.year)
                    , fieldwithLabel "Number of bottles (or cans)" "count" (\val -> Msg.UpdateBeerForm (CountInput val)) (Model.BeerForm.showInt beer.count)
                    , br [] []
                    , div [] <|
                        let
                            name =
                                case beer.id of
                                    Nothing ->
                                        "Add"

                                    Just _ ->
                                        "Save"

                            attributes =
                                if Model.BeerForm.isValid beer then
                                    [ onClickNoPropagation Msg.SubmitBeerForm, class "button-primary" ]
                                else
                                    [ class "button-disabled" ]
                        in
                            [ button attributes
                                [ text name
                                , i [ class "icon-beer" ] []
                                ]
                            , button [ onClickNoPropagation Msg.HideBeerForm, class "" ]
                                [ text "Cancel"
                                , i [ class "icon-cancel" ] []
                                ]
                            ]
                    ]
                ]


fieldwithLabel : String -> String -> (String -> Msg) -> String -> Html Msg
fieldwithLabel labelText tag msg val =
    div []
        [ label [ for <| tag ++ "-input" ]
            [ text labelText ]
        , input
            [ type_ "text"
            , class "u-full-width"
            , id <| tag ++ "-input"
            , onInput msg
            , value val
            , onEnter Msg.SubmitBeerForm
            ]
            []
        ]


buttonWithIcon : String -> String -> msg -> String -> Bool -> Html msg
buttonWithIcon buttonText icon msg classes active =
    button [ onClickNoPropagation msg, class classes ]
        [ text buttonText
        , i [ class <| "icon-" ++ icon ] []
        ]


onEnter : msg -> Attribute msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg
            else
                Json.Decode.fail "not ENTER"
    in
        on "keydown" (Json.Decode.andThen isEnter keyCode)


onClickNoPropagation : msg -> Attribute msg
onClickNoPropagation msg =
    onWithOptions
        "click"
        { defaultOptions | stopPropagation = True }
        (Json.Decode.succeed msg)
