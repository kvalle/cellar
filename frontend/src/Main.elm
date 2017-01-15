module Main exposing (..)

import Array exposing (Array)
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
        { init = init []
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Beer =
    { brewery : String
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


init : List Beer -> ( Model, Cmd Msg )
init beers =
    ( Model beers "" Nothing, getBeers )


filteredBeers : Model -> List Beer
filteredBeers model =
    let
        isMatch string =
            String.contains (String.toLower model.filter) (String.toLower string)

        beerMatches beer =
            isMatch beer.name || isMatch beer.brewery || isMatch beer.style || isMatch (toString beer.year)
    in
        List.filter beerMatches model.beers


updateBeer : (Beer -> Beer) -> Int -> List Beer -> List Beer
updateBeer fn index beers =
    case (Array.get index <| Array.fromList beers) of
        Nothing ->
            beers

        Just beer ->
            Array.toList <| Array.set index (fn beer) <| Array.fromList beers


decrementBeerCount : Int -> List Beer -> List Beer
decrementBeerCount =
    updateBeer (\beer -> { beer | count = beer.count - 1 })


incrementBeerCount : Int -> List Beer -> List Beer
incrementBeerCount =
    updateBeer (\beer -> { beer | count = beer.count + 1 })



-- UPDATE


type Msg
    = Filter String
    | ClearFilter
    | BeerList (Result Http.Error (List Beer))
    | DecrementBeerCount Int
    | IncrementBeerCount Int


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

        DecrementBeerCount index ->
            ( { model | beers = decrementBeerCount index model.beers }, Cmd.none )

        IncrementBeerCount index ->
            ( { model | beers = incrementBeerCount index model.beers }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewTitle
        , viewErrors model
        , viewFilter model
        , viewBeerTable model
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
        [ input [ type_ "search", onInput Filter, value model.filter, placeholder "Filter" ] []
        , i [ onClick ClearFilter, class <| disabledClass (String.isEmpty model.filter) "icon-cancel action" ] []
        ]


viewBeerTable : Model -> Html Msg
viewBeerTable model =
    let
        heading =
            tr [] <| List.map (\name -> th [] [ text name ]) [ "#", "Brewery", "Beer", "Style", "" ]

        rows =
            List.indexedMap viewBeerRow <| filteredBeers model
    in
        table [] <| heading :: rows


viewBeerRow : Int -> Beer -> Html Msg
viewBeerRow index beer =
    tr []
        [ td [ style [ ( "color", "gray" ) ] ] [ text <| toString beer.count ]
        , td [] [ text beer.brewery ]
        , td []
            [ text beer.name
            , span [ style [ ( "padding-left", "10px" ) ] ] [ text <| "(" ++ (toString beer.year) ++ ")" ]
            ]
        , td [ style [ ( "color", "gray" ) ] ] [ text beer.style ]
        , td []
            [ i [ onClick (IncrementBeerCount index), class "action icon-plus" ] []
            , i [ onClick (DecrementBeerCount index), class <| disabledClass (beer.count < 1) "action icon-minus" ] []
            ]
        ]


disabledClass : Bool -> String -> String
disabledClass pred classes =
    if pred then
        classes ++ " disabled"
    else
        classes



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
    Decode.map5 Beer
        (Decode.field "brewery" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "style" Decode.string)
        (Decode.field "year" Decode.int)
        (Decode.field "count" Decode.int)


beerListDecoder : Decode.Decoder (List Beer)
beerListDecoder =
    Decode.list beerDecoder
