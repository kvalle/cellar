module AddNewBeer exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


-- MODEL


type alias Model =
    { brewery : String
    , name : String
    , style : String
    , year : String
    , error : Maybe String
    }


empty : Model
empty =
    Model "" "" "" "" Nothing


updateNewBeerError : Model -> Maybe String -> Model
updateNewBeerError model error =
    { model | error = error }



-- UPDATE


type Msg
    = UpdateBrewery String
    | UpdateName String
    | UpdateYear String
    | UpdateStyle String
    | AddNewBeer


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateBrewery brewery ->
            { model | brewery = brewery }

        UpdateName name ->
            { model | name = name }

        UpdateYear year ->
            { model | year = year }

        UpdateStyle style ->
            { model | style = style }

        AddNewBeer ->
            -- handled by Main for now
            model



-- VIEW


viewAddBeerForm : Model -> Html Msg
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
