module Model.Filters exposing (FilterValue(..), Filters, init, empty, setValue, setContext, matches)

import Model.Beer exposing (Beer)
import Debug


type FilterValue
    = YearMax String
    | CountMin String
    | TextMatches String
    | Styles (List String)


type alias Filters =
    { textMatch : String
    , yearMax : Int
    , countMin : Int
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
        CountMin count ->
            { filters | active = True, countMin = String.toInt count |> Result.withDefault 0 }

        YearMax years ->
            { filters | active = True, yearMax = String.toInt years |> Result.withDefault 0 }

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

        newCountMin =
            if not filters.active || filters.countMin < countMin then
                countMin
            else if filters.countMin > countMax then
                countMax
            else
                filters.countMin
    in
        { filters | countRange = ( Debug.log "min" countMin, countMax ), countMin = newCountMin }


setYearContext : List Beer -> Filters -> Filters
setYearContext beers filters =
    let
        lower =
            List.map .year beers |> List.minimum |> Maybe.withDefault 0

        upper =
            List.map .year beers |> List.maximum |> Maybe.withDefault 0

        newYearMax =
            if not filters.active || filters.yearMax > upper || filters.yearMax < lower then
                upper
            else
                filters.yearMax
    in
        { filters | yearRange = ( lower, upper ), yearMax = newYearMax }


matches : Beer -> Filters -> Bool
matches beer filters =
    let
        textMatch string =
            String.contains (String.toLower filters.textMatch) (String.toLower string)

        matchesText =
            textMatch beer.name || textMatch beer.brewery || textMatch beer.style || textMatch (toString beer.year)

        matchesYearRange =
            beer.year <= filters.yearMax

        matchesCountRange =
            beer.count >= filters.countMin

        matchesStyles =
            List.isEmpty filters.styles || List.member beer.style filters.styles
    in
        matchesText && matchesYearRange && matchesStyles && matchesCountRange
