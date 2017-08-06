module Page.BeerList.View.HtmlExtra exposing (onClickNoPropagation, onKey, onKeys, onKeyWithOptions, onKeysWithOptions)

import Page.BeerList.Model.KeyEvent exposing (KeyEvent)
import Html exposing (Attribute)
import Html.Events exposing (on, onWithOptions, defaultOptions, keyCode)
import Json.Decode


onKeysWithOptions : Html.Events.Options -> List ( KeyEvent, msg ) -> Attribute msg
onKeysWithOptions options mappings =
    let
        decoder mappings actualEvent =
            case List.head mappings of
                Nothing ->
                    Json.Decode.fail "wrong key"

                Just ( keyEvent, msg ) ->
                    if actualEvent == keyEvent then
                        Json.Decode.succeed msg
                    else
                        decoder (List.drop 1 mappings) actualEvent
    in
        onWithOptions
            "keydown"
            options
            (Page.BeerList.Model.KeyEvent.keyEventDecoder |> Json.Decode.andThen (decoder mappings))


onKeys : List ( KeyEvent, msg ) -> Attribute msg
onKeys mappings =
    onKeysWithOptions defaultOptions mappings


onKeyWithOptions : Html.Events.Options -> KeyEvent -> msg -> Attribute msg
onKeyWithOptions options key msg =
    onKeysWithOptions options [ ( key, msg ) ]


onKey : KeyEvent -> msg -> Attribute msg
onKey key msg =
    onKeys [ ( key, msg ) ]


onClickNoPropagation : msg -> Attribute msg
onClickNoPropagation msg =
    onWithOptions
        "click"
        { defaultOptions | stopPropagation = True }
        (Json.Decode.succeed msg)
