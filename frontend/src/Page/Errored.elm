module Page.Errored exposing (view, Model)

import Html exposing (..)


-- MODEL --


type alias Model =
    String



-- VIEW --


view : Model -> Html msg
view model =
    p []
        [ span [] [ text "Error loading page: " ]
        , em [] [ text model ]
        ]
