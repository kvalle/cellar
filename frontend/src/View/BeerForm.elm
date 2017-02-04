module View.BeerForm exposing (viewBeerForm)

import Messages as Msg exposing (Msg)
import Messages.BeerForm exposing (Field(..))
import Model exposing (Model)
import Model.State exposing (DisplayState(..))
import Model.BeerForm exposing (BeerForm)
import View.HtmlExtra exposing (onClickNoPropagation, onEnter)
import Html exposing (..)
import Html.Events exposing (onClick, on, onWithOptions, onInput, defaultOptions, keyCode)
import Html.Attributes exposing (id, class, type_, for, src, title, value, autocomplete)


viewBeerForm : Model -> Html Msg
viewBeerForm model =
    case model.state.beerForm of
        Hidden ->
            text ""

        Visible ->
            let
                form =
                    model.beerForm
            in
                div [ class "modal", onClick Msg.HideBeerForm ]
                    [ div [ class "beer-form", onClickNoPropagation Msg.Noop ]
                        [ h3 []
                            [ case form.data.id of
                                Nothing ->
                                    text "Add beer"

                                Just _ ->
                                    text "Edit beer"
                            ]
                        , fieldwithLabel "Brewery" "brewery" Brewery form form.data.brewery True
                        , fieldwithLabel "Beer Name" "name" Name form form.data.name False
                        , fieldwithLabel "Beer Style" "style" Style form form.data.style True
                        , fieldwithLabel "Production year" "year" Year form (Model.BeerForm.showInt form.data.year) False
                        , fieldwithLabel "Number of bottles (or cans)" "count" Count form (Model.BeerForm.showInt form.data.count) False
                        , fieldwithLabel "Location" "location" Location form (Model.BeerForm.showMaybeString form.data.location) True
                        , fieldwithLabel "Shelf" "shelf" Shelf form (Model.BeerForm.showMaybeString form.data.shelf) True
                        , br [] []
                        , div [] <|
                            let
                                name =
                                    case form.data.id of
                                        Nothing ->
                                            "Add"

                                        Just _ ->
                                            "Save"

                                attributes =
                                    if Model.BeerForm.isValid form.data then
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


suggestions : Field -> List String -> Html Msg
suggestions field values =
    if List.isEmpty values then
        text ""
    else
        let
            showSuggestion name =
                li [ onClick (Msg.UpdateBeerForm field name) ] [ text name ]
        in
            ul [ class "auto-suggestions" ] <|
                List.map showSuggestion values


fieldwithLabel : String -> String -> Field -> BeerForm -> String -> Bool -> Html Msg
fieldwithLabel labelText tag field form val suggestionsEnabled =
    div []
        [ label [ for <| tag ++ "-input" ]
            [ text labelText ]
        , input
            [ type_ "text"
            , class "u-full-width"
            , autocomplete False
            , id <| tag ++ "-input"
            , onInput (Msg.UpdateBeerForm field)
            , value val
            , onEnter Msg.SubmitBeerForm
            ]
            []
        , if suggestionsEnabled then
            suggestions field <| Model.BeerForm.suggestions field form
          else
            text ""
        ]


buttonWithIcon : String -> String -> msg -> String -> Bool -> Html msg
buttonWithIcon buttonText icon msg classes active =
    button [ onClickNoPropagation msg, class classes ]
        [ text buttonText
        , i [ class <| "icon-" ++ icon ] []
        ]
