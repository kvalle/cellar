module Main exposing (..)

import Beer exposing (Beer)
import BeerList exposing (nextAvailableId, updateBeers, updateBeerListError, viewErrors)
import AddNewBeer exposing (updateNewBeerError)
import List
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { beerList : BeerList.Model
    , addBeer : AddNewBeer.Model
    }


init : ( Model, Cmd Msg )
init =
    ( Model BeerList.empty AddNewBeer.empty, getBeers )



-- UPDATE


type Msg
    = RetrievedBeerList (Result Http.Error (List Beer))
    | BeerListMsg BeerList.Msg
    | NewBeerInputMsg AddNewBeer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BeerListMsg msg ->
            ( { model | beerList = BeerList.update msg model.beerList }, Cmd.none )

        NewBeerInputMsg (AddNewBeer.AddNewBeer) ->
            case AddNewBeer.validateForm model.addBeer of
                Ok beer ->
                    let
                        beerList =
                            BeerList.update (BeerList.AddNewBeer beer) model.beerList

                        addBeer =
                            AddNewBeer.update AddNewBeer.ClearForm model.addBeer
                    in
                        ( { model | beerList = beerList, addBeer = addBeer }, Cmd.none )

                Err err ->
                    ( { model | addBeer = updateNewBeerError model.addBeer (Just err) }, Cmd.none )

        NewBeerInputMsg msg ->
            ( { model | addBeer = AddNewBeer.update msg model.addBeer }, Cmd.none )

        RetrievedBeerList (Err _) ->
            ( { model | beerList = updateBeerListError model.beerList <| Just "Unable to load beer list" }, Cmd.none )

        RetrievedBeerList (Ok beers) ->
            ( { model | beerList = updateBeers model.beerList beers }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "twelve columns" ]
                [ viewTitle ]
            ]
        , div [ class "row" ]
            [ div [ class "main seven columns" ]
                [ Html.map BeerListMsg <| BeerList.viewBeerTable model.beerList
                , viewErrors model.beerList
                ]
            , div [ class "sidebar five columns" ]
                [ Html.map BeerListMsg <| BeerList.viewFilter model.beerList
                , Html.map NewBeerInputMsg <| AddNewBeer.viewAddBeerForm model.addBeer
                ]
            ]
        ]


viewTitle : Html Msg
viewTitle =
    h1 []
        [ i [ class "icon-beer" ] []
        , text "Cellar Index"
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
        Http.send RetrievedBeerList (Http.get url beerListDecoder)


beerDecoder : Decode.Decoder Beer
beerDecoder =
    Decode.map6 Beer
        (Decode.nullable (Decode.field "id" Decode.int))
        (Decode.field "brewery" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "style" Decode.string)
        (Decode.field "year" Decode.int)
        (Decode.field "count" Decode.int)


beerListDecoder : Decode.Decoder (List Beer)
beerListDecoder =
    Decode.list beerDecoder
