module View.Filter exposing (viewFilter)

import Messages exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)


viewFilter : String -> Html Msg
viewFilter filter =
    div [ class "filter-form" ]
        [ label [ for "text-filter-input" ] [ text "Text filter" ]
        , input
            [ type_ "search"
            , id "text-filter"
            , onInput UpdateFilter
            , value filter
            , class "u-full-width"
            ]
            []
        , button [ onClick <| UpdateFilter "" ]
            [ text "Clear"
            , i [ class "icon-cancel" ] []
            ]
        ]
