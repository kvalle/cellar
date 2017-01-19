module View.Filter exposing (viewFilter)

import Messages exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)


viewFilter : String -> String -> Html Msg
viewFilter filterText filterAge =
    div [ class "filter-form" ]
        [ label [ for "text-filter-input" ] [ text "Text filter" ]
        , input
            [ type_ "search"
            , id "text-filter"
            , onInput UpdateFilterText
            , value filterText
            , class "u-full-width"
            ]
            []
        , label [ for "age-filter-input" ] [ text <| "Older than (" ++ filterAge ++ " years)" ]
        , input
            [ type_ "range"
            , id "age-filter-input"
            , class "u-full-width"
            , Html.Attributes.min "0"
            , Html.Attributes.max "20"
            , value filterAge
            , onInput UpdateFilterAge
            ]
            []
        , button [ onClick <| UpdateFilterText "" ]
            [ text "Clear"
            , i [ class "icon-cancel" ] []
            ]
        ]
