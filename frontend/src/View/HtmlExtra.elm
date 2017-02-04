module View.HtmlExtra exposing (onClickNoPropagation, onEnter, onTab)

import Html exposing (Attribute)
import Html.Events exposing (on, onWithOptions, defaultOptions, keyCode)
import Json.Decode


onEnter : msg -> Attribute msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg
            else
                Json.Decode.fail "wrong key"
    in
        on "keydown" (Json.Decode.andThen isEnter keyCode)


onTab : msg -> Attribute msg
onTab msg =
    let
        isEnter code =
            if code == 8 then
                Json.Decode.succeed msg
            else
                Json.Decode.fail "wrong key"
    in
        on "keydown" (Json.Decode.andThen isEnter keyCode)


onClickNoPropagation : msg -> Attribute msg
onClickNoPropagation msg =
    onWithOptions
        "click"
        { defaultOptions | stopPropagation = True }
        (Json.Decode.succeed msg)
