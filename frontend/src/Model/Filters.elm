module Model.Filters exposing (FilterValue(..), Filters, init, empty, setValue, setContext, matches)

import Model.Beer exposing (Beer)
import Debug


type FilterValue
    = OlderThan String
    | CountAtLeast String
    | TextMatches String
    | Styles (List String)


type alias Filters =
    { textMatch : String
    , olderThan : Int
    , countAtLeast : Int
    , styles : List String
    , yearRange : ( Int, Int )
    , countRange : ( Int, Int )
    , active : Bool
    }


init : Filters
init =
    Filters "" 0 0 [] ( 0, 0 ) ( 0, 0 ) False


empty : List Beer -> Filters
empty beers =
    init |> setContext beers


setValue : FilterValue -> Filters -> Filters
setValue value filters =
    case value of
        CountAtLeast count ->
            { filters | active = True, countAtLeast = String.toInt count |> Result.withDefault 0 }

        OlderThan years ->
            { filters | active = True, olderThan = String.toInt years |> Result.withDefault 0 }

        TextMatches text ->
            { filters | active = True, textMatch = text }

        Styles styles ->
            { filters | active = True, styles = styles }


setContext : List Beer -> Filters -> Filters
setContext beers filters =
    filters |> setYearContext beers |> setCountContext beers


setCountContext : List Beer -> Filters -> Filters
setCountContext beers filters =
    let
        countMin =
            List.map .count beers |> List.minimum |> Maybe.withDefault 0

        countMax =
            List.map .count beers |> List.maximum |> Maybe.withDefault 0

        newCountAtLeast =
            if not filters.active || filters.countAtLeast < countMin then
                countMin
            else if filters.countAtLeast > countMax then
                countMax
            else
                filters.countAtLeast
    in
        { filters | countRange = ( Debug.log "min" countMin, countMax ), countAtLeast = newCountAtLeast }


setYearContext : List Beer -> Filters -> Filters
setYearContext beers filters =
    let
        yearMin =
            List.map .year beers |> List.minimum |> Maybe.withDefault 0

        yearMax =
            List.map .year beers |> List.maximum |> Maybe.withDefault 0

        newOlderThan =
            if not filters.active || filters.olderThan > yearMax || filters.olderThan < yearMin then
                yearMax
            else
                filters.olderThan
    in
        { filters | yearRange = ( yearMin, yearMax ), olderThan = newOlderThan }


matches : Beer -> Filters -> Bool
matches beer filters =
    let
        textMatch string =
            String.contains (String.toLower filters.textMatch) (String.toLower string)

        matchesText =
            textMatch beer.name || textMatch beer.brewery || textMatch beer.style || textMatch (toString beer.year)

        matchesYearRange =
            beer.year <= filters.olderThan

        matchesCountRange =
            beer.count >= filters.countAtLeast

        matchesStyles =
            List.isEmpty filters.styles || List.member beer.style filters.styles
    in
        matchesText && matchesYearRange && matchesStyles && matchesCountRange
