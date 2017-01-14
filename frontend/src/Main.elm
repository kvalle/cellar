module Main exposing (..)

import List exposing (head, map)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Maybe exposing (withDefault)


beers = [ Beer "Nøgne IPA" "IPA"
        , Beer "Nøgne Imperial Stout" "Imperial Stout"
        , Beer "Cervisiam Jungle Juice" "IPA"
        ]

main =
    Html.program
        { init = init beers
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
    }

init : List Beer -> ( Model, Cmd Msg )
init beers =
    ( Model beers "", Cmd.none )



-- UPDATE


type Msg
    = Filter String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Filter filter ->
            ( { model | filter = filter }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Cellar inventory" ]
        , input [ onInput Filter, value model.filter, placeholder "Filter" ] []
        , br [] []
        , viewBeerList <| filteredBeers model
        ]

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
        , span [ style [("color", "gray"), ("padding-left", "10px")]] [ text beer.style ]
        ]

filteredBeers : Model -> List Beer
filteredBeers model =
    let
        isMatch string = String.contains (String.toLower model.filter) (String.toLower string)
        beerMatches beer = isMatch beer.name || isMatch beer.style
    in
        List.filter beerMatches model.beers 



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


