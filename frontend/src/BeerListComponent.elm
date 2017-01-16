module BeerListComponent exposing (..)

import Beer exposing (Beer)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


-- MODEL


type alias Model =
    { beers : List Beer
    , filter : String
    , error : Maybe String
    }


empty : Model
empty =
    Model [] "" Nothing


updateFilter : Model -> String -> Model
updateFilter model filter =
    { model | filter = filter }


updateBeers : Model -> List Beer -> Model
updateBeers model beers =
    { model | beers = beers }


updateError : Model -> Maybe String -> Model
updateError model error =
    { model | error = error }



-- UPDATE


type Msg
    = UpdateFilter String
    | DecrementBeerCount Beer
    | IncrementBeerCount Beer
    | AddNewBeer Beer


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateFilter filter ->
            { model | filter = filter }

        DecrementBeerCount beer ->
            updateBeers model <| Beer.decrementBeerCount beer model.beers

        IncrementBeerCount beer ->
            updateBeers model <| Beer.incrementBeerCount beer model.beers

        AddNewBeer beer ->
            { model | beers = Beer.addBeer beer model.beers }



-- VIEW


viewErrors : Model -> Html msg
viewErrors model =
    div [ class "errors" ] <|
        case model.error of
            Nothing ->
                []

            Just error ->
                [ text error ]


viewFilter : Model -> Html Msg
viewFilter model =
    div []
        [ h2 [] [ text "Filter beers" ]
        , input [ type_ "search", onInput UpdateFilter, value model.filter, placeholder "Filter" ] []
        , i [ onClick <| UpdateFilter "", class "icon-cancel action" ] []
        ]


viewBeerTable : Model -> Html Msg
viewBeerTable model =
    let
        heading =
            tr [] <| List.map (\name -> th [] [ text name ]) [ "#", "Brewery", "Beer", "Style", "" ]

        rows =
            List.map viewBeerRow <| Beer.filteredBeers model.filter model.beers
    in
        table [] <| heading :: rows


viewBeerRow : Beer -> Html Msg
viewBeerRow beer =
    let
        trClass =
            if beer.count < 1 then
                "zero-row"
            else
                ""
    in
        tr
            [ class trClass ]
            [ td [ class "beer-count" ] [ text <| toString beer.count ]
            , td [] [ text beer.brewery ]
            , td []
                [ text beer.name
                , span [ class "beer-year" ] [ text <| "(" ++ (toString beer.year) ++ ")" ]
                ]
            , td [ class "beer-style" ] [ text beer.style ]
            , td []
                [ viewIncrementCountAction beer
                , viewDecrementCountAction beer
                ]
            ]


viewIncrementCountAction : Beer -> Html Msg
viewIncrementCountAction beer =
    i [ onClick (IncrementBeerCount beer), class "action icon-plus" ] []


viewDecrementCountAction : Beer -> Html Msg
viewDecrementCountAction beer =
    if beer.count < 1 then
        i [ class "action icon-minus disabled" ] []
    else
        i [ onClick (DecrementBeerCount beer), class "action icon-minus" ] []
