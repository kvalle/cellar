module Main exposing (..)

import BeerList exposing (Beer, emptyBeerList, nextAvailableId, updateBeerList, updateBeerListError, viewErrors)
import NewBeerInput exposing (emptyNewBeerInput, updateNewBeerError)
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
    , newBeerInput : NewBeerInput.Model
    }


init : ( Model, Cmd Msg )
init =
    ( Model emptyBeerList emptyNewBeerInput, getBeers )


newBeerInputToBeer : Model -> Result String Beer
newBeerInputToBeer model =
    let
        input =
            model.newBeerInput

        yearResult =
            String.toInt input.year

        allFilledOut =
            not <| List.any String.isEmpty [ input.name, input.year, input.style, input.brewery ]

        id =
            nextAvailableId model.beerList.beers
    in
        case ( allFilledOut, yearResult ) of
            ( False, _ ) ->
                Err "All fields must be filled out"

            ( True, Err err ) ->
                Err err

            ( True, Ok year ) ->
                Ok <| Beer id input.brewery input.name input.style year 1


addNewBeer : Model -> Model
addNewBeer model =
    let
        result =
            newBeerInputToBeer model
    in
        case result of
            Ok beer ->
                { model
                    | beerList = updateBeerList model.beerList (beer :: model.beerList.beers)
                    , newBeerInput = emptyNewBeerInput
                }

            Err err ->
                { model | newBeerInput = updateNewBeerError model.newBeerInput (Just err) }



-- UPDATE


type Msg
    = RetrievedBeerList (Result Http.Error (List Beer))
    | BeerListMsg BeerList.Msg
    | NewBeerInputMsg NewBeerInput.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BeerListMsg msg ->
            ( { model | beerList = BeerList.update msg model.beerList }, Cmd.none )

        NewBeerInputMsg (NewBeerInput.AddNewBeer) ->
            ( addNewBeer model, Cmd.none )

        NewBeerInputMsg msg ->
            ( { model | newBeerInput = NewBeerInput.update msg model.newBeerInput }, Cmd.none )

        RetrievedBeerList (Err _) ->
            ( { model | beerList = updateBeerListError model.beerList <| Just "Unable to load beer list" }, Cmd.none )

        RetrievedBeerList (Ok beers) ->
            ( { model | beerList = updateBeerList model.beerList beers }, Cmd.none )



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
                , Html.map NewBeerInputMsg <| NewBeerInput.viewAddBeerForm model.newBeerInput
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
        (Decode.field "id" Decode.int)
        (Decode.field "brewery" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "style" Decode.string)
        (Decode.field "year" Decode.int)
        (Decode.field "count" Decode.int)


beerListDecoder : Decode.Decoder (List Beer)
beerListDecoder =
    Decode.list beerDecoder
