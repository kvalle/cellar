module Model.Filters exposing (FilterValue(..), Filters, init, empty, setValue, setContext, matches)

import Model.Beer exposing (Beer)


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
    , yearRange : Range
    , countRange : Range
    , active : Bool
    }


type alias Range =
    ( Int, Int )


type RangeDefault
    = DefaultLower
    | DefaultUpper


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


findRange : (Beer -> Int) -> List Beer -> Range
findRange field beers =
    let
        find fn =
            List.map field beers |> fn |> Maybe.withDefault 0
    in
        ( find List.minimum, find List.maximum )


inRange : Bool -> Range -> RangeDefault -> Int -> Int
inRange active ( lower, upper ) default value =
    if not active then
        case default of
            DefaultUpper ->
                upper

            DefaultLower ->
                lower
    else if value < lower then
        lower
    else if value > upper then
        upper
    else
        value


setCountContext : List Beer -> Filters -> Filters
setCountContext beers filters =
    { filters
        | countRange = findRange .count beers
        , countMin = filters.countMin |> inRange filters.active (findRange .count beers) DefaultLower
    }


setYearContext : List Beer -> Filters -> Filters
setYearContext beers filters =
    { filters
        | yearRange = findRange .year beers
        , yearMax = filters.yearMax |> inRange filters.active (findRange .year beers) DefaultUpper
    }


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
