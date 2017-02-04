module View.BeerForm exposing (viewBeerForm)

import Messages as Msg exposing (Msg)
import Messages.BeerForm exposing (Field(..))
import Model exposing (Model)
import Model.State exposing (DisplayState(..))
import Model.BeerForm
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
                        , fieldwithLabel "Brewery" "brewery" (Msg.UpdateBeerForm Brewery) form.data.brewery
                        , suggestions Brewery form.suggestions
                        , fieldwithLabel "Beer Name" "name" (Msg.UpdateBeerForm Name) form.data.name
                        , fieldwithLabel "Beer Style" "style" (Msg.UpdateBeerForm Style) form.data.style
                        , fieldwithLabel "Production year" "year" (Msg.UpdateBeerForm Year) (Model.BeerForm.showInt form.data.year)
                        , fieldwithLabel "Number of bottles (or cans)" "count" (Msg.UpdateBeerForm Count) (Model.BeerForm.showInt form.data.count)
                        , fieldwithLabel "Location" "location" (Msg.UpdateBeerForm Location) (Model.BeerForm.showMaybeString form.data.location)
                        , fieldwithLabel "Shelf" "shelf" (Msg.UpdateBeerForm Shelf) (Model.BeerForm.showMaybeString form.data.shelf)
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
    let
        showSuggestion name =
            li [ onClick (Msg.UpdateBeerForm field name) ] [ text name ]
    in
        ul [] <|
            List.map showSuggestion values


fieldwithLabel : String -> String -> (String -> Msg) -> String -> Html Msg
fieldwithLabel labelText tag msg val =
    div []
        [ label [ for <| tag ++ "-input" ]
            [ text labelText ]
        , input
            [ type_ "text"
            , class "u-full-width"
            , autocomplete False
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
