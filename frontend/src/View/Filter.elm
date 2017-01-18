module View.Filter exposing (viewFilter)

import Messages exposing (Msg(..))
import Html exposing (Html, h2, div, text, input, i)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


viewFilter : String -> Html Msg
viewFilter filter =
    div [ class "filter-form" ]
        [ input [ type_ "search", onInput UpdateFilter, value filter, placeholder "Filter" ] []
        , i [ onClick <| UpdateFilter "", class "icon-cancel action" ] []
        ]
