module View.HtmlExtra exposing (onClickNoPropagation, onEnter, onTab, onKey, arrowUp, arrowDown, enter, tab)

import Html exposing (Attribute)
import Html.Events exposing (on, onWithOptions, defaultOptions, keyCode)
import Json.Decode
import Debug


type alias Key =
    Int


enter : Key
enter =
    13


tab : Key
tab =
    8


arrowDown : Key
arrowDown =
    40


arrowUp : Key
arrowUp =
    38


escape : Key
escape =
    27


onKey : List ( Key, msg ) -> Attribute msg
onKey mappings =
    let
        isKey mappings code =
            case List.head mappings of
                Nothing ->
                    Json.Decode.fail "wrong key"

                Just ( key, msg ) ->
                    if Debug.log "key: " code == key then
                        Json.Decode.succeed msg
                    else
                        case List.tail mappings of
                            Nothing ->
                                Json.Decode.fail "wrong key"

                            Just tail ->
                                isKey tail code
    in
        on "keydown" (Json.Decode.andThen (isKey mappings) keyCode)


onEnter : msg -> Attribute msg
onEnter msg =
    onKey [ ( enter, msg ) ]


onTab : msg -> Attribute msg
onTab msg =
    onKey [ ( tab, msg ) ]


onClickNoPropagation : msg -> Attribute msg
onClickNoPropagation msg =
    onWithOptions
        "click"
        { defaultOptions | stopPropagation = True }
        (Json.Decode.succeed msg)
