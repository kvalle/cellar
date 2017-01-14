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
    }


type alias Model =
    { beers : List Beer
    , filter : String
    , error : Maybe String
    }


init : List Beer -> ( Model, Cmd Msg )
init beers =
    ( Model beers "" Nothing, getBeers )



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
        [ h2 [] [ text "Cellar inventory" ]
        , viewErrors model
        , input [ onInput Filter, value model.filter, placeholder "Filter" ] []
        , br [] []
        , viewBeerList <| filteredBeers model
        ]

viewErrors : Model -> Html Msg
viewErrors model =
    div [ style [("color", "red")] ] <| case model.error of
            Nothing -> []
            Just error -> [ text error ]

viewBeerList : List Beer -> Html Msg
viewBeerList beers =
    div []
        [ h3 [] [ text "Beers:" ]
        , div [] <| List.map viewBeerItem beers
        ]


viewBeerItem : Beer -> Html Msg
viewBeerItem beer =
    div []
        [ span [] [ text beer.name ]
        , span [ style [ ( "color", "gray" ), ( "padding-left", "10px" ) ] ] [ text beer.style ]
        ]


filteredBeers : Model -> List Beer
filteredBeers model =
    let
        isMatch string =
            String.contains (String.toLower model.filter) (String.toLower string)

        beerMatches beer =
            isMatch beer.name || isMatch beer.style
    in
        List.filter beerMatches model.beers



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
    Decode.map2 Beer (Decode.field "name" Decode.string) (Decode.field "style" Decode.string)


beerListDecoder : Decode.Decoder (List Beer)
beerListDecoder =
    Decode.list beerDecoder
