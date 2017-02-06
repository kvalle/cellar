module View.HtmlExtra exposing (onClickNoPropagation, onKey, onKeys, onKeysWithOptions, keys)

import Html exposing (Attribute)
import Html.Events exposing (on, onWithOptions, defaultOptions, keyCode)
import Json.Decode


type alias Key =
    Int


keys :
    { arrowDown : Key
    , arrowUp : Key
    , enter : Key
    , escape : Key
    , tab : Key
    }
keys =
    { enter = 13
    , tab = 8
    , arrowDown = 40
    , arrowUp = 38
    , escape = 27
    }


onKeysWithOptions : Html.Events.Options -> List ( Key, msg ) -> Attribute msg
onKeysWithOptions options mappings =
    let
        decoder mappings code =
            case List.head mappings of
                Nothing ->
                    Json.Decode.fail "wrong key"

                Just ( key, msg ) ->
                    if code == key then
                        Json.Decode.succeed msg
                    else
                        decoder (List.drop 1 mappings) code
    in
        onWithOptions
            "keydown"
            options
            (keyCode |> Json.Decode.andThen (decoder mappings))


onKeys : List ( Key, msg ) -> Attribute msg
onKeys mappings =
    onKeysWithOptions defaultOptions mappings


onKey : Key -> msg -> Attribute msg
onKey key msg =
    onKeys [ ( key, msg ) ]


onClickNoPropagation : msg -> Attribute msg
onClickNoPropagation msg =
    onWithOptions
        "click"
        { defaultOptions | stopPropagation = True }
        (Json.Decode.succeed msg)
