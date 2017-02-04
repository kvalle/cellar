module Model.BeerForm exposing (BeerForm, empty, init, from, withInput, isValid, showInt, showMaybeString, suggestions, selectedSuggestion)

import Messages.BeerForm exposing (Field(..))
import Model.Beer exposing (Beer)
import Set


type alias BeerForm =
    { data : Beer
    , possibleSuggestions : List ( Field, List String )
    , suggestions : List ( Field, List String )
    , selectedSuggestions : List ( Field, Int )
    }


type alias Dict k v =
    List ( k, v )


type alias Suggestions =
    Dict Field (List String)


init : BeerForm
init =
    empty []


empty : List Beer -> BeerForm
empty context =
    from Model.Beer.empty context


from : Beer -> List Beer -> BeerForm
from beer context =
    let
        unique field =
            context |> List.map field |> Set.fromList |> Set.toList

        uniqueMaybe field =
            context |> List.filterMap field |> Set.fromList |> Set.toList
    in
        { data = beer
        , possibleSuggestions =
            [ ( Brewery, unique .brewery )
            , ( Style, unique .style )
            , ( Location, uniqueMaybe .location )
            , ( Shelf, uniqueMaybe .shelf )
            ]
        , suggestions = [ ( Brewery, [ "Foobar", "Bar", "Baz" ] ), ( Style, [] ), ( Location, [] ), ( Shelf, [] ) ]
        , selectedSuggestions = [ ( Brewery, 0 ), ( Style, 0 ), ( Location, 0 ), ( Shelf, 0 ) ]
        }


withInput : Field -> String -> BeerForm -> BeerForm
withInput field input form =
    { form
        | data = form.data |> updateField field input
        , suggestions = dictUpdate field (findRelevantSuggestions input field form.possibleSuggestions) form.suggestions
    }


updateField : Field -> String -> Beer -> Beer
updateField field input beer =
    case field of
        Brewery ->
            { beer | brewery = input }

        Name ->
            { beer | name = input }

        Style ->
            { beer | style = input }

        Year ->
            { beer | year = toIntWithDefault input beer.year }

        Count ->
            { beer | count = toIntWithDefault input beer.count }

        Location ->
            { beer | location = toMaybeString input beer.location }

        Shelf ->
            { beer | shelf = toMaybeString input beer.shelf }


dictLookup : k -> v -> Dict k v -> v
dictLookup key default dict =
    case
        (List.head <| List.filter (\( k, _ ) -> k == key) dict)
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


suggestions : Field -> BeerForm -> List String
suggestions field form =
    dictLookup field [] form.suggestions


selectedSuggestion : Field -> BeerForm -> Int
selectedSuggestion field form =
    dictLookup field 0 form.selectedSuggestions


findRelevantSuggestions : String -> Field -> Suggestions -> List String
findRelevantSuggestions input field allPossible =
    let
        possible =
            dictLookup field [] allPossible

        contains suggestion =
            String.contains (String.toLower input) suggestion
                && (suggestion /= (String.toLower input))
                && (input /= "")
    in
        List.filter (contains << String.toLower) possible


showInt : Int -> String
showInt num =
    if num == 0 then
        ""
    else
        toString num


showMaybeString : Maybe String -> String
showMaybeString optional =
    optional |> Maybe.withDefault ""


toIntWithDefault : String -> Int -> Int
toIntWithDefault str default =
    if str == "" then
        0
    else
        String.toInt str |> Result.withDefault default


toMaybeString : String -> Maybe String -> Maybe String
toMaybeString str default =
    if str == "" then
        Nothing
    else
        Just str


isValid : Beer -> Bool
isValid beer =
    let
        notEmpty =
            not << String.isEmpty
    in
        notEmpty beer.brewery
            && notEmpty beer.name
            && notEmpty beer.style
            && (beer.year > 0)
            && (beer.count > 0)
