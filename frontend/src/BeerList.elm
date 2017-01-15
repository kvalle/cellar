module BeerList exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


-- MODEL


type alias Model =
    { beers : List Beer
    , filter : String
    , error : Maybe String
    }


type alias Beer =
    { id : Int
    , brewery : String
    , name : String
    , style : String
    , year : Int
    , count : Int
    }


emptyBeerList : Model
emptyBeerList =
    Model [] "" Nothing


filteredBeers : Model -> List Beer
filteredBeers beerList =
    let
        isMatch string =
            String.contains (String.toLower beerList.filter) (String.toLower string)

        beerMatches beer =
            isMatch beer.name || isMatch beer.brewery || isMatch beer.style || isMatch (toString beer.year)
    in
        List.filter beerMatches beerList.beers


updateBeer : (Beer -> Beer) -> Beer -> List Beer -> List Beer
updateBeer fn original beers =
    let
        update beer =
            if beer.id == original.id then
                fn beer
            else
                beer
    in
        List.map update beers


decrementBeerCount : Beer -> List Beer -> List Beer
decrementBeerCount =
    updateBeer (\beer -> { beer | count = beer.count - 1 })


incrementBeerCount : Beer -> List Beer -> List Beer
incrementBeerCount =
    updateBeer (\beer -> { beer | count = beer.count + 1 })


nextAvailableId : List Beer -> Int
nextAvailableId beers =
    case List.map .id beers |> List.maximum of
        Nothing ->
            1

        Just n ->
            n + 1


updateFilter : Model -> String -> Model
updateFilter beerList filter =
    { beerList | filter = filter }


updateBeerList : Model -> List Beer -> Model
updateBeerList beerList beers =
    { beerList | beers = beers }


updateBeerListError : Model -> Maybe String -> Model
updateBeerListError beerList error =
    { beerList | error = error }



-- UPDATE


type Msg
    = UpdateFilter String
    | DecrementBeerCount Beer
    | IncrementBeerCount Beer


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateFilter filter ->
            updateFilter model filter

        DecrementBeerCount beer ->
            updateBeerList model <| decrementBeerCount beer model.beers

        IncrementBeerCount beer ->
            updateBeerList model <| incrementBeerCount beer model.beers



-- VIEW


viewErrors : Model -> Html msg
viewErrors beerList =
    div [ class "errors" ] <|
        case beerList.error of
            Nothing ->
                []

            Just error ->
                [ text error ]


viewFilter : Model -> Html Msg
viewFilter beerList =
    div []
        [ h2 [] [ text "Filter beers" ]
        , input [ type_ "search", onInput UpdateFilter, value beerList.filter, placeholder "Filter" ] []
        , i [ onClick <| UpdateFilter "", class "icon-cancel action" ] []
        ]


viewBeerTable : Model -> Html Msg
viewBeerTable beerList =
    let
        heading =
            tr [] <| List.map (\name -> th [] [ text name ]) [ "#", "Brewery", "Beer", "Style", "" ]

        rows =
            List.map viewBeerRow <| filteredBeers beerList
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
