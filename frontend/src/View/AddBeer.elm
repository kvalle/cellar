module View.AddBeer exposing (viewAddBeerForm)

import Messages exposing (Msg(..))
import Model.Beer exposing (Beer)
import Model.NewBeerForm exposing (NewBeerForm)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


viewAddBeerForm : NewBeerForm -> Html Msg
viewAddBeerForm model =
    div []
        [ h2 [] [ text "Add beer" ]
        , input [ type_ "text", placeholder "brewery", onInput UpdateBrewery, value model.brewery ] []
        , input [ type_ "text", placeholder "name", onInput UpdateName, value model.name ] []
        , input [ type_ "text", placeholder "year", onInput UpdateYear, value model.year ] []
        , input [ type_ "text", placeholder "style", onInput UpdateStyle, value model.style ] []
        , button [ onClick AddNewBeer ]
            [ i [ class "icon-beer" ] []
            , text "Add"
            ]
        , span [ class "errors" ] <|
            case model.error of
                Nothing ->
                    []

                Just error ->
                    [ text error ]
        ]
