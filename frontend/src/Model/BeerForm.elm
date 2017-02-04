module Model.BeerForm exposing (BeerForm, empty, init, from, withInput, isValid, showInt, showMaybeString)

import Messages.BeerForm exposing (Field(..))
import Model.Beer exposing (Beer)
import Set


type alias BeerForm =
    { data : Beer
    , possibleSuggestions : List String
    , suggestions : List String
    }


init : BeerForm
init =
    empty []


empty : List Beer -> BeerForm
empty context =
    from Model.Beer.empty context


from : Beer -> List Beer -> BeerForm
from beer context =
    { data = beer
    , possibleSuggestions = context |> List.map .brewery |> Set.fromList |> Set.toList
    , suggestions = []
    }


updatedSuggestions : String -> List String -> List String
updatedSuggestions input possible =
    let
        contains suggestion =
            String.contains (String.toLower input) suggestion
                && (suggestion /= (String.toLower input))
                && (input /= "")
    in
        List.filter (contains << String.toLower) possible


withInput : Field -> String -> BeerForm -> BeerForm
withInput field input form =
    let
        beer =
            form.data
    in
        case field of
            Brewery ->
                { form
                    | data = { beer | brewery = input }
                    , suggestions = updatedSuggestions input form.possibleSuggestions
                }

            Name ->
                { form
                    | data = { beer | name = input }
                }

            Style ->
                { form
                    | data = { beer | style = input }
                }

            Year ->
                { form
                    | data = { beer | year = toIntWithDefault input beer.year }
                }

            Count ->
                { form
                    | data = { beer | count = toIntWithDefault input beer.count }
                }

            Location ->
                { form
                    | data = { beer | location = toMaybeString input beer.location }
                }

            Shelf ->
                { form
                    | data = { beer | shelf = toMaybeString input beer.shelf }
                }


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
