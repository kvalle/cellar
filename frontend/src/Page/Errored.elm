module Page.Errored exposing (view, Model)

import Html exposing (Html, div, h1, img, main_, p, text, em)


-- MODEL --


type alias Model =
    String



-- VIEW --


view : Model -> Html msg
view model =
    div []
        [ p [] [ text "Error Loading Page" ]
        , p [] [ em [] [ text model ] ]
        ]
