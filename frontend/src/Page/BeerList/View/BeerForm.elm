module Page.BeerList.View.BeerForm exposing (viewBeerForm)

import Page.BeerList.Messages as Msg exposing (Msg)
import Page.BeerList.Messages.BeerForm exposing (Field(..), SuggestionMsg(..))
import Page.BeerList.Model exposing (Model)
import Page.BeerList.Model.State exposing (DisplayState(..))
import Page.BeerList.Model.BeerForm exposing (BeerForm)
import Data.KeyEvent exposing (keys)
import Page.BeerList.View.HtmlExtra exposing (onClickNoPropagation, onKeysWithOptions)
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
                div [ class "modal", onClick Msg.HideForm ]
                    [ div [ class "beer-form", onClickNoPropagation Msg.Noop ]
                        [ formTitle form
                        , fieldwithLabel "Brewery" "brewery" Brewery form True
                        , fieldwithLabel "Beer Name" "name" Name form True
                        , fieldwithLabel "Beer Style" "style" Style form True
                        , fieldwithLabel "Production year" "year" Year form False
                        , fieldwithLabel "Volume (in liters)" "volume" Volume form False
                        , fieldwithLabel "Alcohol by volume (ABV)" "abv" Abv form False
                        , fieldwithLabel "Number of bottles (or cans)" "count" Count form False
                        , fieldwithLabel "Location" "location" Location form True
                        , fieldwithLabel "Shelf" "shelf" Shelf form True
                        , br [] []
                        , formControlButtons model.beerForm
                        ]
                    ]


formTitle : BeerForm -> Html Msg
formTitle form =
    h3 []
        [ case form.id of
            Nothing ->
                text "Add beer"

            Just _ ->
                text "Edit beer"
        ]


formControlButtons : BeerForm -> Html Msg
formControlButtons form =
    let
        name =
            case form.id of
                Nothing ->
                    "Add"

                Just _ ->
                    "Save"

        attributes =
            if Page.BeerList.Model.BeerForm.isValid form then
                [ onClickNoPropagation Msg.SubmitForm, class "button-primary" ]
            else
                [ class "button-disabled" ]
    in
        div []
            [ button attributes
                [ text name
                , i [ class "icon-beer" ] []
                ]
            , button [ onClickNoPropagation Msg.HideForm, class "" ]
                [ text "Cancel"
                , i [ class "icon-cancel" ] []
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
            , onInput <| Msg.UpdateFormField field
            , value <| Page.BeerList.Model.BeerForm.show field form
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


suggestions : Field -> BeerForm -> Html Msg
suggestions field form =
    let
        selectedIndex =
            Page.BeerList.Model.BeerForm.selectedSuggestion field form

        values =
            Page.BeerList.Model.BeerForm.suggestions field form
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
