module View.BeerForm exposing (viewBeerForm)

import Messages as Msg exposing (Msg)
import Messages.BeerForm exposing (Field(..), SuggestionMsg(..))
import Model exposing (Model)
import Model.State exposing (DisplayState(..))
import Model.BeerForm exposing (BeerForm)
import View.HtmlExtra exposing (onClickNoPropagation, onKeys, keys)
import Html exposing (..)
import Html.Events exposing (onClick, on, onWithOptions, onInput, defaultOptions, keyCode, onBlur)
import Html.Attributes exposing (id, class, type_, for, src, title, value, autocomplete, classList)


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
                        , fieldwithLabel "Brewery" "brewery" Brewery form True
                        , fieldwithLabel "Beer Name" "name" Name form False
                        , fieldwithLabel "Beer Style" "style" Style form True
                        , fieldwithLabel "Production year" "year" Year form False
                        , fieldwithLabel "Number of bottles (or cans)" "count" Count form False
                        , fieldwithLabel "Location" "location" Location form True
                        , fieldwithLabel "Shelf" "shelf" Shelf form True
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
                                    if Model.BeerForm.isValid form then
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


fieldwithLabel : String -> String -> Field -> BeerForm -> Bool -> Html Msg
fieldwithLabel labelText tag field form suggestionsEnabled =
    div [ class "fieldset" ]
        [ label [ for <| tag ++ "-input" ]
            [ text labelText ]
        , input
            [ type_ "text"
            , class "u-full-width"
            , autocomplete False
            , id <| tag ++ "-input"
            , onInput (Msg.UpdateBeerForm field)
            , value <| Model.BeerForm.show field form
            , onBlur <| Msg.UpdateSuggestions field Clear
            , onKeys
                [ ( keys.enter, Msg.UpdateSuggestions field Select )
                , ( keys.arrowUp, Msg.UpdateSuggestions field Previous )
                , ( keys.arrowDown, Msg.UpdateSuggestions field Next )
                , ( keys.escape, Msg.UpdateSuggestions field Clear )
                ]
            ]
            []
        , if suggestionsEnabled then
            suggestions field form
          else
            text ""
        ]


suggestions : Field -> BeerForm -> Html Msg
suggestions field form =
    let
        selected =
            Model.BeerForm.selectedSuggestion field form

        values =
            Model.BeerForm.suggestions field form
    in
        if List.isEmpty values then
            text ""
        else
            let
                showSuggestion index name =
                    li
                        [ onClick (Msg.UpdateBeerForm field name)
                        , classList [ ( "selected", index == selected ) ]
                        ]
                        [ text name ]
            in
                ul [ class "auto-suggestions" ] <|
                    List.indexedMap showSuggestion values
