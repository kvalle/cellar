module View.HtmlExtra exposing (onClickNoPropagation, onKey, onKeys, onKeyWithOptions, onKeysWithOptions, keys)

import Html exposing (Attribute)
import Html.Events exposing (on, onWithOptions, defaultOptions, keyCode)
import Json.Decode
import Json.Decode.Pipeline as Pipeline


-- TODO: remove


type alias KeyEvent =
    { key : Int
    , ctrl : Bool
    , shift : Bool
    , alt : Bool
    , meta : Bool
    }


fromKeyCode : Int -> KeyEvent
fromKeyCode code =
    KeyEvent code False False False False


keyEventDecoder : Json.Decode.Decoder KeyEvent
keyEventDecoder =
    Pipeline.decode KeyEvent
        |> Pipeline.required "keyCode" Json.Decode.int
        |> Pipeline.required "ctrlKey" Json.Decode.bool
        |> Pipeline.required "shiftKey" Json.Decode.bool
        |> Pipeline.required "altKey" Json.Decode.bool
        |> Pipeline.required "metaKey" Json.Decode.bool


keys :
    { arrowDown : KeyEvent
    , arrowUp : KeyEvent
    , enter : KeyEvent
    , escape : KeyEvent
    , tab : KeyEvent
    }
keys =
    { enter = fromKeyCode 13
    , tab = fromKeyCode 8
    , arrowDown = fromKeyCode 40
    , arrowUp = fromKeyCode 38
    , escape = fromKeyCode 27
    }


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
            (keyEventDecoder |> Json.Decode.andThen (decoder mappings))


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
