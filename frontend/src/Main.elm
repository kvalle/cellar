module Main exposing (..)

import Messages exposing (Msg(..))
import Subscriptions exposing (subscriptions)
import Commands exposing (fetchBeerList)
import Model.Beer as Beer exposing (Beer)
import Model.NewBeerForm as NewBeerForm exposing (NewBeerForm)
import Model.Tab exposing (Tab(..))
import Model.Filter as Filter exposing (FilterValue(..), Filters, empty)
import View.BeerList exposing (viewBeerList)
import View.AddBeer exposing (viewAddBeerForm)
import View.Filter exposing (viewFilter)
import View.Tabs exposing (viewTabs)
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
    , filters : Filters
    , error : Maybe String
    , tab : Tab
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] NewBeerForm.empty Filter.empty Nothing FilterTab, fetchBeerList )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RetrievedBeerList (Err _) ->
            ( { model | error = Just "Unable to load beer list" }, Cmd.none )

        RetrievedBeerList (Ok beers) ->
            ( { model | beerList = beers }, Cmd.none )

        ChangeTab tab ->
            ( { model | tab = tab }, Cmd.none )

        ClearFilter ->
            ( { model | filters = Filter.empty }, Cmd.none )

        UpdateFilter value ->
            ( { model | filters = Filter.setValue model.filters value }, Cmd.none )

        DecrementBeerCount beer ->
            ( { model | beerList = Beer.decrementBeerCount beer model.beerList }, Cmd.none )

        IncrementBeerCount beer ->
            ( { model | beerList = Beer.incrementBeerCount beer model.beerList }, Cmd.none )

        UpdateAddBeerInput input ->
            ( { model | addBeerForm = NewBeerForm.setInput input model.addBeerForm }, Cmd.none )

        SubmitAddBeer ->
            case NewBeerForm.validate model.addBeerForm of
                Just beer ->
                    ( { model | beerList = Beer.addBeer beer model.beerList, addBeerForm = NewBeerForm.empty }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | addBeerForm = NewBeerForm.markAsSubmitted model.addBeerForm }, Cmd.none )

        ClearAddBeer ->
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
                [ viewBeerList model.filters model.beerList
                , viewErrors model.error
                ]
            , div [ class "sidebar five columns" ]
                [ viewTabs model.tab
                , case model.tab of
                    FilterTab ->
                        viewFilter model.filters

                    AddBeerTab ->
                        viewAddBeerForm model.addBeerForm
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
