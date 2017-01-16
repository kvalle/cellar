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

        BeerListMessage msg ->
            ( { model | beerList = updateBeerList msg model.beerList }, Cmd.none )

        AddBeerMessage AddNewBeer ->
            case NewBeerForm.validate model.addBeer of
                Ok beer ->
                    let
                        beerList =
                            updateBeerList (AddBeerToList beer) model.beerList

                        addBeer =
                            updateNewBeerForm ClearForm model.addBeer
                    in
                        ( { model | beerList = beerList, addBeer = addBeer }, Cmd.none )

                Err err ->
                    ( { model | addBeer = NewBeerForm.updateError model.addBeer (Just err) }, Cmd.none )

        AddBeerMessage msg ->
            ( { model | addBeer = updateNewBeerForm msg model.addBeer }, Cmd.none )

        RetrievedBeerList (Err _) ->
            ( { model | error = Just "Unable to load beer list" }, Cmd.none )

        RetrievedBeerList (Ok beers) ->
            ( { model | beerList = beers }, Cmd.none )


updateBeerList : BeerListMsg -> List Beer -> List Beer
updateBeerList msg model =
    case msg of
        DecrementBeerCount beer ->
            Beer.decrementBeerCount beer model

        IncrementBeerCount beer ->
            Beer.incrementBeerCount beer model

        AddBeerToList beer ->
            Beer.addBeer beer model


updateNewBeerForm : AddBeerMsg -> NewBeerForm -> NewBeerForm
updateNewBeerForm msg model =
    case msg of
        UpdateBrewery brewery ->
            { model | brewery = brewery }

        UpdateName name ->
            { model | name = name }

        UpdateYear year ->
            { model | year = year }

        UpdateStyle style ->
            { model | style = style }

        ClearForm ->
            NewBeerForm.empty

        AddNewBeer ->
            -- handled by Main for now
            model



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
                [ Html.map BeerListMessage <| viewBeerList model.filter model.beerList
                , viewErrors model.error
                ]
            , div [ class "sidebar five columns" ]
                [ viewFilter model.filter
                , Html.map AddBeerMessage <| viewAddBeerForm model.addBeer
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
