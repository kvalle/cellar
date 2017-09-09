module Page.BeerForm.View exposing (view)

import Page.BeerForm.Messages as Msg exposing (Msg, Field(..), SuggestionMsg(..))
import Page.BeerForm.Model exposing (Model, FormState(..))
import Data.KeyEvent exposing (keys)
import Views.HtmlAttributes exposing (onClickNoPropagation, onKeysWithOptions)
import Html exposing (..)
import Html.Events exposing (onClick, on, onWithOptions, onInput, defaultOptions, keyCode, onBlur)
import Html.Attributes exposing (id, class, type_, for, src, title, value, autocomplete, classList)


view : Model -> Html Msg
view form =
    div [ class "beer-form" ]
        [ formTitle form
        , fieldwithLabel "Brewery" "brewery" Brewery form True
        , fieldwithLabel "Beer Name" "name" Name form True
        , fieldwithLabel "Beer Style" "style" Style form True
        , fieldwithLabel "Production year" "year" Year form False
        , fieldwithLabel "Volume (in liters)" "volume" Volume form False
        , fieldwithLabel "Alcohol by volume (ABV)" "abv" Abv form False
        , fieldwithLabel "Number of bottles or cans" "count" Count form False
        , fieldwithLabel "Location" "location" Location form True
        , fieldwithLabel "Shelf" "shelf" Shelf form True
        , br [] []
        , formControlButtons form
        ]


formTitle : Model -> Html Msg
formTitle form =
    h3 []
        [ case form.id of
            Nothing ->
                text "Add new beer"

            Just _ ->
                text "Edit beer"
        ]


formControlButtons : Model -> Html Msg
formControlButtons form =
    let
        name =
            case ( form.state, form.id ) of
                ( Saving, _ ) ->
                    "Saving..."

                ( Editing, Nothing ) ->
                    "Add beer"

                ( Editing, Just _ ) ->
                    "Save changes"

        attributes =
            if Page.BeerForm.Model.isValid form then
                [ onClick Msg.SubmitForm, class "button-primary" ]
            else
                [ class "button-disabled" ]
    in
        div []
            [ button attributes
                [ text name
                , i [ class "icon-beer" ] []
                ]
            , button [ onClick Msg.CancelForm ]
                [ text "Cancel"
                , i [ class "icon-cancel" ] []
                ]
            , span []
                [ case form.error of
                    Nothing ->
                        text ""

                    Just err ->
                        text <| "Error: " ++ err
                ]
            ]


fieldwithLabel : String -> String -> Field -> Model -> Bool -> Html Msg
fieldwithLabel labelText tag field form suggestionsEnabled =
    div [ class "fieldset" ]
        [ label [ for <| tag ++ "-input" ]
            [ text labelText ]
        , input
            [ type_ "text"
            , class "u-full-width"
            , autocomplete False
            , id <| tag ++ "-input"
            , onInput <| Msg.UpdateFormField field
            , value <| Page.BeerForm.Model.show field form
            , onBlur <| Msg.UpdateFormSuggestions field Clear
            , onKeysWithOptions
                { defaultOptions | preventDefault = True }
                [ ( keys.enter, Msg.UpdateFormSuggestions field Select )
                , ( keys.arrowUp, Msg.UpdateFormSuggestions field Previous )
                , ( keys.arrowDown, Msg.UpdateFormSuggestions field Next )
                , ( keys.escape, Msg.UpdateFormSuggestions field Clear )
                ]
            ]
            []
        , if suggestionsEnabled then
            suggestions field form
          else
            text ""
        ]


suggestions : Field -> Model -> Html Msg
suggestions field form =
    let
        selectedIndex =
            Page.BeerForm.Model.selectedSuggestion field form

        values =
            Page.BeerForm.Model.suggestions field form
    in
        if List.isEmpty values then
            text ""
        else
            let
                showSuggestion index name =
                    li
                        [ onClick (Msg.UpdateFormField field name)
                        , classList [ ( "selected", index == selectedIndex ) ]
                        ]
                        [ text name ]
            in
                ul [ class "auto-suggestions" ] <|
                    List.indexedMap showSuggestion values
