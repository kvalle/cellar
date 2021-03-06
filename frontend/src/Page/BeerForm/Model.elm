module Page.BeerForm.Model
    exposing
        ( Model
        , FormState(..)
        , initEmpty
        , initWith
        , empty
        , updateField
        , updateSuggestions
        , suggestions
        , selectedSuggestion
        , isValid
        , show
        , toBeer
        )

import Backend.Beers
import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(..))
import Data.Beer exposing (Beer)
import Data.BeerList
import Http
import Page.BeerForm.Messages exposing (Field(..), SuggestionMsg(..))
import Page.Errored
import Set
import Task


type alias Dict k v =
    List ( k, v )


type FormState
    = Editing
    | Saving


type alias Model =
    { id : Maybe Int
    , state : FormState
    , error : Maybe String
    , fields : Dict Field String
    , possibleSuggestions : Dict Field (List String)
    , suggestions : Dict Field (List String)
    , selectedSuggestions : Dict Field Int
    }



{- Initialize form -}


initEmpty : AppState -> Task.Task Page.Errored.Model Model
initEmpty appState =
    let
        loadBeers userData =
            Backend.Beers.get appState.environment userData |> Http.toTask
    in
        case appState.auth of
            LoggedIn userData ->
                Task.map empty (loadBeers userData)
                    |> Task.mapError (\_ -> "Unable to load beer list :(")

            LoggedOut ->
                Task.fail <| "Need to be logged in to add beers"


initWith : Int -> AppState -> Task.Task Page.Errored.Model Model
initWith beerId appState =
    let
        loadBeers userData =
            Backend.Beers.get appState.environment userData |> Http.toTask

        initForm beers =
            case Data.BeerList.getById beerId beers of
                Nothing ->
                    Task.fail <| "Couldn't find any beers with id " ++ (toString beerId)

                Just beer ->
                    Task.succeed <| from beer beers
    in
        case appState.auth of
            LoggedIn userData ->
                loadBeers userData
                    |> Task.mapError (\_ -> "Unable to load beer list :(")
                    |> Task.andThen initForm

            LoggedOut ->
                Task.fail <| "Need to be logged in to add beers"


empty : List Beer -> Model
empty context =
    let
        unique field =
            context |> List.map field |> Set.fromList |> Set.toList

        uniqueMaybe field =
            context |> List.filterMap field |> Set.fromList |> Set.toList
    in
        { id = Nothing
        , state = Editing
        , error = Nothing
        , fields =
            [ ( Brewery, "" )
            , ( Name, "" )
            , ( Style, "" )
            , ( Year, "" )
            , ( Count, "" )
            , ( Volume, "" )
            , ( Abv, "" )
            , ( Location, "" )
            , ( Shelf, "" )
            ]
        , possibleSuggestions =
            [ ( Brewery, unique .brewery )
            , ( Name, unique .name )
            , ( Style, unique .style )
            , ( Location, uniqueMaybe .location )
            , ( Shelf, uniqueMaybe .shelf )
            ]
        , suggestions = dictInit [] [ Brewery, Name, Style, Location, Shelf ]
        , selectedSuggestions = dictInit 0 [ Brewery, Name, Style, Location, Shelf ]
        }


from : Beer -> List Beer -> Model
from beer context =
    let
        emptyForm =
            empty context
    in
        { emptyForm
            | id = Just beer.id
            , fields =
                [ ( Brewery, beer.brewery )
                , ( Name, beer.name )
                , ( Style, beer.style )
                , ( Year, toString beer.year )
                , ( Count, toString beer.count )
                , ( Volume, toString beer.volume )
                , ( Abv, toString beer.abv )
                , ( Location, beer.location |> Maybe.withDefault "" )
                , ( Shelf, beer.shelf |> Maybe.withDefault "" )
                ]
        }


updateField : Field -> String -> Model -> Model
updateField field input form =
    { form | fields = form.fields |> dictUpdate field input }


updateSuggestions : Field -> SuggestionMsg -> Model -> Model
updateSuggestions field msg form =
    case msg of
        Next ->
            let
                newIndex =
                    updateSuggestionIndex ((+) 1) field form
            in
                { form | selectedSuggestions = form.selectedSuggestions |> dictUpdate field newIndex }

        Previous ->
            let
                newIndex =
                    updateSuggestionIndex (\n -> n - 1) field form
            in
                { form | selectedSuggestions = form.selectedSuggestions |> dictUpdate field newIndex }

        Clear ->
            { form | suggestions = dictUpdate field [] form.suggestions }

        Select ->
            let
                suggestion =
                    suggestions field form
                        |> List.drop (dictLookup field 0 form.selectedSuggestions)
                        |> List.head
                        |> Maybe.withDefault ""
            in
                if suggestion == "" then
                    form
                else
                    form
                        |> updateField field suggestion
                        |> updateSuggestions field Refresh

        Refresh ->
            let
                relevant =
                    List.take 20 <| findRelevantSuggestions field form
            in
                { form
                    | suggestions =
                        form.suggestions
                            |> dictUpdate field relevant
                }


toBeer : Model -> List Beer -> Beer
toBeer form context =
    { id = form.id |> Maybe.withDefault (Data.BeerList.nextAvailableId context)
    , brewery = form |> show Brewery
    , name = form |> show Name
    , style = form |> show Style
    , year = form |> show Year |> String.toInt |> Result.withDefault 0
    , count = form |> show Count |> String.toInt |> Result.withDefault 0
    , volume = form |> show Volume |> String.toFloat |> Result.withDefault 0.0
    , abv = form |> show Abv |> String.toFloat |> Result.withDefault 0.0
    , location = form |> show Location |> toMaybe ((/=) "")
    , shelf = form |> show Shelf |> toMaybe ((/=) "")
    }


suggestions : Field -> Model -> List String
suggestions field form =
    dictLookup field [] form.suggestions


selectedSuggestion : Field -> Model -> Int
selectedSuggestion field form =
    dictLookup field 0 form.selectedSuggestions


isValid : Model -> Bool
isValid form =
    List.all identity
        [ show Brewery form |> not << String.isEmpty
        , show Name form |> not << String.isEmpty
        , show Style form |> not << String.isEmpty
        , show Count form |> String.toInt |> Result.map (\n -> n > 0) |> Result.withDefault False
        , show Volume form |> String.toFloat |> Result.map (\n -> n > 0) |> Result.withDefault False
        , show Year form |> String.toInt |> Result.map (\n -> n > 0) |> Result.withDefault False
        ]


show : Field -> Model -> String
show field form =
    dictLookup field "" form.fields



{- Helper functions -}


dictInit : v -> List k -> Dict k v
dictInit val =
    List.map (\f -> ( f, val ))


dictLookup : k -> v -> Dict k v -> v
dictLookup key default dict =
    case
        dict
            |> List.filter (\( k, _ ) -> k == key)
            |> List.head
    of
        Nothing ->
            default

        Just ( _, value ) ->
            value


dictUpdate : k -> v -> Dict k v -> Dict k v
dictUpdate key value dict =
    let
        update ( k, v ) =
            if k == key then
                ( key, value )
            else
                ( k, v )
    in
        List.map update dict


findRelevantSuggestions : Field -> Model -> List String
findRelevantSuggestions field form =
    let
        input =
            show field form

        contains suggestion =
            String.contains (String.toLower input) suggestion
                && (suggestion /= (String.toLower input))
                && (input /= "")
    in
        List.filter (contains << String.toLower) <| dictLookup field [] form.possibleSuggestions


toMaybe : (a -> Bool) -> a -> Maybe a
toMaybe pred a =
    if pred a then
        Just a
    else
        Nothing


updateSuggestionIndex : (Int -> Int) -> Field -> Model -> Int
updateSuggestionIndex fn field form =
    let
        numberOfSuggestions =
            suggestions field form |> List.length

        index =
            fn <| dictLookup field 0 form.selectedSuggestions
    in
        if numberOfSuggestions == 0 then
            0
        else if index < 0 then
            numberOfSuggestions - 1
        else if index >= numberOfSuggestions then
            0
        else
            index
