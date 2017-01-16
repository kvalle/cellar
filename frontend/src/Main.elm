module Main exposing (..)

import Messages exposing (..)
import Subscriptions exposing (subscriptions)
import Beer exposing (Beer)
import BeerListComponent
import AddBeerComponent
import FilterComponent
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
    { beerList : BeerListComponent.Model
    , addBeer : AddBeerComponent.Model
    , filter : String
    , error : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( Model BeerListComponent.empty AddBeerComponent.empty "" Nothing, getBeers )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateFilter filter ->
            ( { model | filter = filter }, Cmd.none )

        BeerListMessage msg ->
            ( { model | beerList = BeerListComponent.update msg model.beerList }, Cmd.none )

        AddBeerMessage AddNewBeer ->
            case AddBeerComponent.validateForm model.addBeer of
                Ok beer ->
                    let
                        beerList =
                            BeerListComponent.update (AddBeerToList beer) model.beerList

                        addBeer =
                            AddBeerComponent.update ClearForm model.addBeer
                    in
                        ( { model | beerList = beerList, addBeer = addBeer }, Cmd.none )

                Err err ->
                    ( { model | addBeer = AddBeerComponent.updateError model.addBeer (Just err) }, Cmd.none )

        AddBeerMessage msg ->
            ( { model | addBeer = AddBeerComponent.update msg model.addBeer }, Cmd.none )

        RetrievedBeerList (Err _) ->
            ( { model | error = Just "Unable to load beer list" }, Cmd.none )

        RetrievedBeerList (Ok beers) ->
            ( { model | beerList = BeerListComponent.updateBeers model.beerList beers }, Cmd.none )



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
                [ Html.map BeerListMessage <| BeerListComponent.viewBeerTable model.filter model.beerList.beers
                , viewErrors model.error
                ]
            , div [ class "sidebar five columns" ]
                [ FilterComponent.viewFilter model.filter
                , Html.map AddBeerMessage <| AddBeerComponent.viewAddBeerForm model.addBeer
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
