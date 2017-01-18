module View.Tabs exposing (viewTabs)

import Messages exposing (Msg(..))
import Model.Tab exposing (Tab(..))
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


viewTab : String -> Tab -> Tab -> Html Msg
viewTab string selected tab =
    let
        classes =
            if selected == tab then
                "tab selected"
            else
                "tab"
    in
        span
            [ class classes, onClick (ChangeTab tab) ]
            [ text string ]


viewTabs : Tab -> Html Msg
viewTabs selected =
    div [ class "tabs" ]
        [ viewTab "Filter" selected FilterTab
        , viewTab "Add new" selected AddBeerTab
        ]
