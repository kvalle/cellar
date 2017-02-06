module View.HtmlExtra exposing (onClickNoPropagation, onKey, onKeys, keys)

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


onKeys : List ( Key, msg ) -> Attribute msg
onKeys mappings =
    let
        isKey mappings code =
            case List.head mappings of
                Nothing ->
                    Json.Decode.fail "wrong key"

                Just ( key, msg ) ->
                    if code == key then
                        Json.Decode.succeed msg
                    else
                        case List.tail mappings of
                            Nothing ->
                                Json.Decode.fail "wrong key"

                            Just tail ->
                                isKey tail code
    in
        onWithOptions
            "keydown"
            { defaultOptions
                | stopPropagation = True
                , preventDefault = True
            }
            (Json.Decode.andThen (isKey mappings) keyCode)


onKey : Key -> msg -> Attribute msg
onKey key msg =
    onKeys [ ( key, msg ) ]


onClickNoPropagation : msg -> Attribute msg
onClickNoPropagation msg =
    onWithOptions
        "click"
        { defaultOptions | stopPropagation = True }
        (Json.Decode.succeed msg)
