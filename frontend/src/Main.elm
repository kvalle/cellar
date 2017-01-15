module Main exposing (..)

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


type alias Beer =
    { id : Int
    , brewery : String
    , name : String
    , style : String
    , year : Int
    , count : Int
    }


type alias NewBeerInput =
    { brewery : String
    , name : String
    , style : String
    , year : String
    }


type alias Model =
    { beers : List Beer
    , filter : String
    , error : Maybe String
    , newBeerInput : NewBeerInput
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] "" Nothing (NewBeerInput "" "" "" ""), getBeers )


filteredBeers : Model -> List Beer
filteredBeers model =
    let
        isMatch string =
            String.contains (String.toLower model.filter) (String.toLower string)

        beerMatches beer =
            isMatch beer.name || isMatch beer.brewery || isMatch beer.style || isMatch (toString beer.year)
    in
        List.filter beerMatches model.beers


updateBeer : (Beer -> Beer) -> Beer -> List Beer -> List Beer
updateBeer fn original beers =
    let
        update beer =
            if beer.id == original.id then
                fn beer
            else
                beer
    in
        List.map update beers


decrementBeerCount : Beer -> List Beer -> List Beer
decrementBeerCount =
    updateBeer (\beer -> { beer | count = beer.count - 1 })


incrementBeerCount : Beer -> List Beer -> List Beer
incrementBeerCount =
    updateBeer (\beer -> { beer | count = beer.count + 1 })


nextAvailableId : List Beer -> Int
nextAvailableId beers =
    case List.map .id beers |> List.maximum of
        Nothing ->
            1

        Just n ->
            n + 1


updateBrewery newBeerInput brewery =
    { newBeerInput | brewery = brewery }


updateName newBeerInput name =
    { newBeerInput | name = name }


updateStyle newBeerInput style =
    { newBeerInput | style = style }


updateYear newBeerInput year =
    { newBeerInput | year = year }


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
            nextAvailableId model.beers
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
                { model | beers = beer :: model.beers, newBeerInput = NewBeerInput "" "" "" "" }

            Err err ->
                { model | error = Just err }



-- UPDATE


type Msg
    = Filter String
    | ClearFilter
    | BeerList (Result Http.Error (List Beer))
    | DecrementBeerCount Beer
    | IncrementBeerCount Beer
    | AddNewBeer
    | UpdateInputBrewery String
    | UpdateInputName String
    | UpdateInputYear String
    | UpdateInputStyle String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Filter filter ->
            ( { model | filter = filter }, Cmd.none )

        ClearFilter ->
            ( { model | filter = "" }, Cmd.none )

        BeerList (Err _) ->
            ( { model | error = Just "Unable to load beer list" }, Cmd.none )

        BeerList (Ok beers) ->
            ( { model | beers = beers }, Cmd.none )

        DecrementBeerCount beer ->
            ( { model | beers = decrementBeerCount beer model.beers }, Cmd.none )

        IncrementBeerCount beer ->
            ( { model | beers = incrementBeerCount beer model.beers }, Cmd.none )

        AddNewBeer ->
            ( addNewBeer model, Cmd.none )

        UpdateInputBrewery brewery ->
            ( { model | newBeerInput = updateBrewery model.newBeerInput brewery }, Cmd.none )

        UpdateInputName name ->
            ( { model | newBeerInput = updateName model.newBeerInput name }, Cmd.none )

        UpdateInputYear year ->
            ( { model | newBeerInput = updateYear model.newBeerInput year }, Cmd.none )

        UpdateInputStyle style ->
            ( { model | newBeerInput = updateStyle model.newBeerInput style }, Cmd.none )



--UpdateInputBrewery brewery ->
--    ( {model | newBeerInput = {model.newBeerInput | brewery = brewery}}, Cmd.none )
--            UpdateInputName name ->
--    ( {model | newBeerInput = {model.newBeerInput | name = name}}, Cmd.none )
--            UpdateInputYear year ->
--    ( {model | newBeerInput = {model.newBeerInput | year = year}}, Cmd.none )
--            UpdateInputStyle style ->
--    ( {model | newBeerInput = {model.newBeerInput | style = style}}, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "twelve columns" ]
                [ viewTitle
                , viewErrors model
                ]
            ]
        , div [ class "row" ]
            [ div [ class "main seven columns" ] [ viewBeerTable model ]
            , div [ class "sidebar five columns" ]
                [ viewFilter model
                , viewAddBeerForm model
                ]
            ]
        ]


viewTitle : Html Msg
viewTitle =
    h1 []
        [ i [ onClick ClearFilter, class "icon-beer" ] []
        , text "Cellar Index"
        ]


viewErrors : Model -> Html Msg
viewErrors model =
    div [ class "errors" ] <|
        case model.error of
            Nothing ->
                []

            Just error ->
                [ text error ]


viewFilter : Model -> Html Msg
viewFilter model =
    div []
        [ h2 [] [ text "Filter beers" ]
        , input [ type_ "search", onInput Filter, value model.filter, placeholder "Filter" ] []
        , i [ onClick ClearFilter, class "icon-cancel action" ] []
        ]


viewAddBeerForm : Model -> Html Msg
viewAddBeerForm model =
    div []
        [ h2 [] [ text "Add beer" ]
        , input [ type_ "text", placeholder "brewery", onInput UpdateInputBrewery, value model.newBeerInput.brewery ] []
        , input [ type_ "text", placeholder "name", onInput UpdateInputName, value model.newBeerInput.name ] []
        , input [ type_ "text", placeholder "year", onInput UpdateInputYear, value model.newBeerInput.year ] []
        , input [ type_ "text", placeholder "style", onInput UpdateInputStyle, value model.newBeerInput.style ] []
        , button [ onClick AddNewBeer ]
            [ i [ class "icon-beer" ] []
            , text "Add"
            ]
        ]


viewBeerTable : Model -> Html Msg
viewBeerTable model =
    let
        heading =
            tr [] <| List.map (\name -> th [] [ text name ]) [ "#", "Brewery", "Beer", "Style", "" ]

        rows =
            List.map viewBeerRow <| filteredBeers model
    in
        table [] <| heading :: rows


viewBeerRow : Beer -> Html Msg
viewBeerRow beer =
    let
        trClass =
            if beer.count < 1 then
                "zero-row"
            else
                ""
    in
        tr
            [ class trClass ]
            [ td [ class "beer-count" ] [ text <| toString beer.count ]
            , td [] [ text beer.brewery ]
            , td []
                [ text beer.name
                , span [ class "beer-year" ] [ text <| "(" ++ (toString beer.year) ++ ")" ]
                ]
            , td [ class "beer-style" ] [ text beer.style ]
            , td []
                [ viewIncrementCountAction beer
                , viewDecrementCountAction beer
                ]
            ]


viewIncrementCountAction : Beer -> Html Msg
viewIncrementCountAction beer =
    i [ onClick (IncrementBeerCount beer), class "action icon-plus" ] []


viewDecrementCountAction : Beer -> Html Msg
viewDecrementCountAction beer =
    if beer.count < 1 then
        i [ class "action icon-minus disabled" ] []
    else
        i [ onClick (DecrementBeerCount beer), class "action icon-minus" ] []



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
