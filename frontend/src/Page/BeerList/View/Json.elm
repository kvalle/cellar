module Page.BeerList.View.Json exposing (viewJsonModal)

import Page.BeerList.Messages as Msg exposing (Msg)
import Page.BeerList.Model exposing (Model)
import Page.BeerList.Model.State exposing (DisplayState(..))
import Data.Beer exposing (encoder, listEncoder)
import Page.BeerList.View.HtmlExtra exposing (onClickNoPropagation)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Json.Encode


viewJsonModal : Model -> Html Msg
viewJsonModal model =
    case model.state.jsonModal of
        Hidden ->
            text ""

        Visible ->
            let
                json =
                    listEncoder model.beers

                jsonString =
                    Json.Encode.encode 4 json
            in
                div [ class "modal", onClick Msg.HideJsonModal ]
                    [ div [ onClickNoPropagation Msg.ShowJsonModal ]
                        [ h3 [] [ text "Your beers as JSON" ]
                        , pre [ class "json" ] [ text jsonString ]
                        ]
                    ]
