module Main exposing (..)

import Messages exposing (Msg(..))
import Subscriptions exposing (subscriptions)
import Commands exposing (fetchBeerList)
import Model.Beer as Beer exposing (Beer)
import Model.NewBeerForm as NewBeerForm exposing (NewBeerForm)
import View.BeerList exposing (viewBeerList)
import View.AddBeer exposing (viewAddBeerForm)
import View.Filter exposing (viewFilter)
import Html exposing (..)
import Html.Attributes exposing (class)


main : Program Never Model Msg
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
    , addBeerForm : NewBeerForm
    , filterString : String
    , error : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] NewBeerForm.empty "" Nothing, fetchBeerList )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateFilter filter ->
            ( { model | filterString = filter }, Cmd.none )

        AddNewBeer ->
            case NewBeerForm.validate model.addBeerForm of
                Just beer ->
                    ( { model | beerList = Beer.addBeer beer model.beerList, addBeerForm = NewBeerForm.empty }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | addBeerForm = NewBeerForm.markAsSubmitted model.addBeerForm }, Cmd.none )

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

        UpdateInput input ->
            ( { model | addBeerForm = NewBeerForm.setInput input model.addBeerForm }, Cmd.none )

        ClearNewBeerForm ->
            ( { model | addBeerForm = NewBeerForm.empty }, Cmd.none )



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
                [ viewBeerList model.filterString model.beerList
                , viewErrors model.error
                ]
            , div [ class "sidebar five columns" ]
                [ viewFilter model.filterString
                , viewAddBeerForm model.addBeerForm
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
