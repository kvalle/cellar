module Main exposing (..)

import List exposing (head, map)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Maybe exposing (withDefault)
import Debug


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Beer =
    { id : Int
    , brewery : String
    , name : String
    , style : String
    , year : Int
    , count : Int
    }


type alias Model =
    { beers : List Beer
    , filter : String
    , error : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] "" Nothing, getBeers )


filteredBeers : Model -> List Beer
filteredBeers model =
    let
        isMatch string =
            String.contains (String.toLower model.filter) (String.toLower string)

        beerMatches beer =
            isMatch beer.name || isMatch beer.brewery || isMatch beer.style || isMatch (toString beer.year)
    in
        List.filter beerMatches model.beers


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



-- UPDATE


type Msg
    = Filter String
    | ClearFilter
    | BeerList (Result Http.Error (List Beer))
    | DecrementBeerCount Beer
    | IncrementBeerCount Beer


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Filter filter ->
            ( { model | filter = filter }, Cmd.none )

        ClearFilter ->
            ( { model | filter = "" }, Cmd.none )

        BeerList (Err _) ->
            ( { model | error = Just "Unable to load beer list" }, Cmd.none )

        BeerList (Ok beers) ->
            ( { model | beers = beers }, Cmd.none )

        DecrementBeerCount beer ->
            ( { model | beers = decrementBeerCount beer model.beers }, Cmd.none )

        IncrementBeerCount beer ->
            ( { model | beers = incrementBeerCount beer model.beers }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "twelve columns" ]
                [ viewTitle
                , viewErrors model
                ]
            ]
        , div [ class "row" ]
            [ div [ class "main seven columns" ] [ viewBeerTable model ]
            , div [ class "sidebar five columns" ]
                [ viewFilter model
                , viewAddBeerForm
                ]
            ]
        ]


viewTitle : Html Msg
viewTitle =
    h1 []
        [ i [ onClick ClearFilter, class "icon-beer" ] []
        , text "Cellar Index"
        ]


viewErrors : Model -> Html Msg
viewErrors model =
    div [ style [ ( "color", "red" ) ] ] <|
        case model.error of
            Nothing ->
                []

            Just error ->
                [ text error ]


viewFilter : Model -> Html Msg
viewFilter model =
    div []
        [ h2 [] [ text "Filter beers" ]
        , input [ type_ "search", onInput Filter, value model.filter, placeholder "Filter" ] []
        , i [ onClick ClearFilter, class "icon-cancel action" ] []
        ]


viewAddBeerForm : Html Msg
viewAddBeerForm =
    div []
        [ h2 [] [ text "Add beer" ]
        , input [ type_ "text", placeholder "brewery" ] []
        , input [ type_ "text", placeholder "name" ] []
        , input [ type_ "text", placeholder "style" ] []
        , button []
            [ i [ class "icon-beer" ] []
            , text "Add "
            ]
        ]


viewBeerTable : Model -> Html Msg
viewBeerTable model =
    let
        heading =
            tr [] <| List.map (\name -> th [] [ text name ]) [ "#", "Brewery", "Beer", "Style", "" ]

        rows =
            List.map viewBeerRow <| filteredBeers model
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getBeers : Cmd Msg
getBeers =
    let
        url =
            "http://localhost:9000/api/beers"
    in
        Http.send BeerList (Http.get url beerListDecoder)


beerDecoder : Decode.Decoder Beer
beerDecoder =
    Decode.map6 Beer
        (Decode.field "id" Decode.int)
        (Decode.field "brewery" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "style" Decode.string)
        (Decode.field "year" Decode.int)
        (Decode.field "count" Decode.int)


beerListDecoder : Decode.Decoder (List Beer)
beerListDecoder =
    Decode.list beerDecoder
