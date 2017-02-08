module Model.BeerForm exposing (BeerForm, empty, init, from, updateField, updateSuggestions, suggestions, selectedSuggestion, isValid, show, toBeer)

import Messages.BeerForm exposing (Field(..), SuggestionMsg(..))
import Model.Beer exposing (Beer)
import Set


type alias Dict k v =
    List ( k, v )


type alias BeerForm =
    { id : Maybe Int
    , fields : Dict Field String
    , possibleSuggestions : Dict Field (List String)
    , suggestions : Dict Field (List String)
    , selectedSuggestions : Dict Field Int
    }



{- Initialize form -}


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
        { id = beer.id
        , fields =
            [ ( Brewery, beer.brewery )
            , ( Name, beer.name )
            , ( Style, beer.style )
            , ( Year, toString beer.year )
            , ( Count, toString beer.count )
            , ( Volume, toString beer.volume )
            , ( Location, beer.location |> Maybe.withDefault "" )
            , ( Shelf, beer.shelf |> Maybe.withDefault "" )
            ]
        , possibleSuggestions =
            [ ( Brewery, unique .brewery )
            , ( Style, unique .style )
            , ( Location, uniqueMaybe .location )
            , ( Shelf, uniqueMaybe .shelf )
            ]
        , suggestions = [ ( Brewery, [] ), ( Style, [] ), ( Location, [] ), ( Shelf, [] ) ]
        , selectedSuggestions = [ ( Brewery, 0 ), ( Style, 0 ), ( Location, 0 ), ( Shelf, 0 ) ]
        }


updateField : Field -> String -> BeerForm -> BeerForm
updateField field input form =
    { form | fields = form.fields |> dictUpdate field input }


updateSuggestions : Field -> SuggestionMsg -> BeerForm -> BeerForm
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
            { form
                | suggestions =
                    form.suggestions |> dictUpdate field (findRelevantSuggestions field form)
            }



{- Getters -}


toBeer : BeerForm -> Beer
toBeer form =
    { id = form.id
    , brewery = form |> show Brewery
    , name = form |> show Name
    , style = form |> show Style
    , year = form |> show Year |> String.toInt |> Result.withDefault 0
    , count = form |> show Count |> String.toInt |> Result.withDefault 0
    , volume = form |> show Volume |> String.toFloat |> Result.withDefault 0.0
    , location = form |> show Location |> toMaybe ((/=) "")
    , shelf = form |> show Shelf |> toMaybe ((/=) "")
    }


suggestions : Field -> BeerForm -> List String
suggestions field form =
    dictLookup field [] form.suggestions


selectedSuggestion : Field -> BeerForm -> Int
selectedSuggestion field form =
    dictLookup field 0 form.selectedSuggestions


isValid : BeerForm -> Bool
isValid form =
    let
        beer =
            toBeer form

        notEmpty =
            not << String.isEmpty
    in
        notEmpty beer.brewery
            && notEmpty beer.name
            && notEmpty beer.style
            && (beer.year > 0)
            && (beer.count > 0)
            && (beer.volume > 0.0)


show : Field -> BeerForm -> String
show field form =
    dictLookup field "" form.fields



{- Helper functions -}


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


findRelevantSuggestions : Field -> BeerForm -> List String
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


updateSuggestionIndex : (Int -> Int) -> Field -> BeerForm -> Int
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
