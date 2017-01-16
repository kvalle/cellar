module Main exposing (..)

import Messages exposing (..)
import Subscriptions exposing (subscriptions)
import Beer exposing (Beer)
import NewBeerForm exposing (NewBeerForm)
import View.BeerList exposing (viewBeerList)
import View.AddBeer exposing (viewAddBeerForm)
import View.Filter exposing (viewFilter)
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
    { beerList : List Beer
    , addBeer : NewBeerForm
    , filter : String
    , error : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] NewBeerForm.empty "" Nothing, getBeers )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateFilter filter ->
            ( { model | filter = filter }, Cmd.none )

        AddNewBeer ->
            case NewBeerForm.validate model.addBeer of
                Ok beer ->
                    let
                        beerList =
                            Beer.addBeer beer model.beerList

                        addBeer =
                            NewBeerForm.empty
                    in
                        ( { model | beerList = beerList, addBeer = addBeer }, Cmd.none )

                Err err ->
                    ( { model | addBeer = NewBeerForm.updateError model.addBeer (Just err) }, Cmd.none )

        RetrievedBeerList (Err _) ->
            ( { model | error = Just "Unable to load beer list" }, Cmd.none )

        RetrievedBeerList (Ok beers) ->
            ( { model | beerList = beers }, Cmd.none )

        DecrementBeerCount beer ->
            ( { model | beerList = Beer.decrementBeerCount beer model.beerList }, Cmd.none )

        IncrementBeerCount beer ->
            ( { model | beerList = Beer.incrementBeerCount beer model.beerList }, Cmd.none )

        AddBeerToList beer ->
            ( { model | beerList = Beer.addBeer beer model.beerList }, Cmd.none )

        UpdateBrewery brewery ->
            ( { model | addBeer = NewBeerForm.updateBrewery model.addBeer brewery }, Cmd.none )

        UpdateName name ->
            ( { model | addBeer = NewBeerForm.updateName model.addBeer name }, Cmd.none )

        UpdateYear year ->
            ( { model | addBeer = NewBeerForm.updateYear model.addBeer year }, Cmd.none )

        UpdateStyle style ->
            ( { model | addBeer = NewBeerForm.updateStyle model.addBeer style }, Cmd.none )



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
                [ viewBeerList model.filter model.beerList
                , viewErrors model.error
                ]
            , div [ class "sidebar five columns" ]
                [ viewFilter model.filter
                , viewAddBeerForm model.addBeer
                ]
            ]
        ]


viewErrors : Maybe String -> Html msg
viewErrors error =
    div [ class "errors" ] <|
        case error of
            Nothing ->
                []

            Just error ->
                [ text error ]


viewTitle : Html Msg
viewTitle =
    h1 []
        [ i [ class "icon-beer" ] []
        , text "Cellar Index"
        ]



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
