module View.BeerForm exposing (viewBeerForm)

import Messages as Msg exposing (Msg)
import Model exposing (Model)
import Model.State exposing (DisplayState(..))
import Model.BeerForm exposing (BeerInput(..))
import View.HtmlExtra exposing (onClickNoPropagation, onEnter)
import Html exposing (..)
import Html.Events exposing (onClick, on, onWithOptions, onInput, defaultOptions, keyCode)
import Html.Attributes exposing (id, class, type_, for, src, title, value)


viewBeerForm : Model -> Html Msg
viewBeerForm model =
    case model.state.beerForm of
        Hidden ->
            text ""

        Visible ->
            div [ class "modal", onClick Msg.HideBeerForm ]
                [ div [ class "beer-form", onClickNoPropagation (Msg.ShowEditBeerForm model.beerForm) ]
                    [ h3 []
                        [ case model.beerForm.id of
                            Nothing ->
                                text "Add beer"

                            Just _ ->
                                text "Edit beer"
                        ]
                    , fieldwithLabel "Brewery" "brewery" (Msg.UpdateBeerForm << BreweryInput) model.beerForm.brewery
                    , fieldwithLabel "Beer Name" "name" (Msg.UpdateBeerForm << NameInput) model.beerForm.name
                    , fieldwithLabel "Beer Style" "style" (Msg.UpdateBeerForm << StyleInput) model.beerForm.style
                    , fieldwithLabel "Production year" "year" (Msg.UpdateBeerForm << YearInput) (Model.BeerForm.showInt model.beerForm.year)
                    , fieldwithLabel "Number of bottles (or cans)" "count" (Msg.UpdateBeerForm << CountInput) (Model.BeerForm.showInt model.beerForm.count)
                    , fieldwithLabel "Location" "location" (Msg.UpdateBeerForm << LocationInput) (Model.BeerForm.showMaybeString model.beerForm.location)
                    , fieldwithLabel "Shelf" "shelf" (Msg.UpdateBeerForm << ShelfInput) (Model.BeerForm.showMaybeString model.beerForm.shelf)
                    , br [] []
                    , div [] <|
                        let
                            name =
                                case model.beerForm.id of
                                    Nothing ->
                                        "Add"

                                    Just _ ->
                                        "Save"

                            attributes =
                                if Model.BeerForm.isValid model.beerForm then
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
