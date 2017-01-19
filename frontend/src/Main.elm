module Main exposing (..)

import Messages exposing (Msg(..))
import Subscriptions exposing (subscriptions)
import Commands exposing (fetchBeers)
import Model.Beer exposing (Beer)
import Model.BeerForm exposing (BeerForm)
import Model.Tab exposing (Tab(..))
import Model.Filter exposing (FilterValue(..), Filters)
import View.BeerList exposing (viewBeerList)
import View.BeerForm exposing (viewBeerForm)
import View.Filter exposing (viewFilter)
import View.Tabs exposing (viewTabs)
import Update.Beer as Beer
import Update.Filter as Filter
import Update.BeerForm as BeerForm
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
    { beers : List Beer
    , beerForm : BeerForm
    , filters : Filters
    , error : Maybe String
    , tab : Tab
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] BeerForm.empty Filter.empty Nothing FilterTab, fetchBeers )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RetrievedBeerList (Err _) ->
            ( { model | error = Just "Unable to load beer list" }, Cmd.none )

        RetrievedBeerList (Ok beers) ->
            ( { model | beers = beers, filters = Filter.setContext beers model.filters }, Cmd.none )

        ChangeTab tab ->
            ( { model | tab = tab }, Cmd.none )

        ClearFilter ->
            ( { model | filters = Filter.setContext model.beers Filter.empty }, Cmd.none )

        UpdateFilter value ->
            ( { model | filters = Filter.setValue model.filters value }, Cmd.none )

        DecrementBeer beer ->
            ( { model | beers = Beer.decrement beer model.beers }, Cmd.none )

        IncrementBeer beer ->
            ( { model | beers = Beer.increment beer model.beers }, Cmd.none )

        UpdateBeerForm input ->
            ( { model | beerForm = BeerForm.setInput input model.beerForm }, Cmd.none )

        SubmitBeerForm ->
            case BeerForm.toBeer model.beerForm of
                Just beer ->
                    let
                        beerList =
                            Beer.add beer model.beers
                    in
                        ( { model
                            | beers = beerList
                            , beerForm = BeerForm.empty
                            , filters = Filter.setContext beerList model.filters
                          }
                        , Cmd.none
                        )

                Nothing ->
                    ( { model | beerForm = BeerForm.markSubmitted model.beerForm }, Cmd.none )

        ClearBeerForm ->
            ( { model | beerForm = BeerForm.empty }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "main seven columns" ]
                [ viewTitle ]
            , div [ class "sidebar five columns" ]
                [ viewTabs model.tab ]
            ]
        , div [ class "row" ]
            [ div [ class "main seven columns" ]
                [ viewBeerList model.filters model.beers
                , viewErrors model.error
                ]
            , div [ class "sidebar five columns" ]
                [ case model.tab of
                    FilterTab ->
                        viewFilter model.filters

                    AddBeerTab ->
                        viewBeerForm model.beerForm
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
