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
        { init = init []
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Beer =
    { name : String
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
            isMatch beer.name || isMatch beer.style
    in
        List.filter beerMatches model.beers



-- UPDATE


type Msg
    = Filter String
    | BeerList (Result Http.Error (List Beer))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Filter filter ->
            ( { model | filter = filter }, Cmd.none )

        BeerList (Err _) ->
            ( { model | error = Just "Unable to load beer list" }, Cmd.none )

        BeerList (Ok beers) ->
            ( { model | beers = beers }, Cmd.none )



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
    h2 [] [ text "Beer Cellar Index" ]


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
    input [ onInput Filter, value model.filter, placeholder "Filter" ] []


viewBeerTable : Model -> Html Msg
viewBeerTable model =
    let
        heading =
            tr [] <| List.map (\name -> th [] [ text name ]) [ "#", "Beer", "Style" ]

        rows =
            List.map viewBeerRow <| filteredBeers model
    in
        table [] <| heading :: rows


viewBeerRow : Beer -> Html Msg
viewBeerRow beer =
    tr []
        [ td [ style [ ( "color", "gray" ) ] ] [ text <| toString beer.count ]
        , td []
            [ text beer.name
            , span [ style [ ( "padding-left", "10px" ) ] ] [ text <| "(" ++ (toString beer.year) ++ ")" ]
            ]
        , td [ style [ ( "color", "gray" ), ( "padding-left", "10px" ) ] ] [ text beer.style ]
        ]



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
    Decode.map4 Beer
        (Decode.field "name" Decode.string)
        (Decode.field "style" Decode.string)
        (Decode.field "year" Decode.int)
        (Decode.field "count" Decode.int)


beerListDecoder : Decode.Decoder (List Beer)
beerListDecoder =
    Decode.list beerDecoder
