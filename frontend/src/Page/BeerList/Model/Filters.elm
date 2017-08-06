module Page.BeerList.Model.Filters exposing (FilterValue(..), Filters, init, empty, setValue, setContext, matches)

import Page.BeerList.Model.Beer exposing (Beer)


type FilterValue
    = YearMax String
    | CountMin String
    | Text String
    | Locations (List String)
    | Styles (List String)


type alias Filters =
    { textMatch : String
    , locations : List String
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
    { textMatch = ""
    , locations = []
    , yearMax = 0
    , countMin = 0
    , styles = []
    , yearRange = ( 0, 0 )
    , countRange = ( 0, 0 )
    , active = False
    }


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

        Text text ->
            { filters | active = True, textMatch = text }

        Locations locations ->
            { filters | active = True, locations = locations }

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
        textMatch =
            List.any
                (String.contains (String.toLower filters.textMatch) << String.toLower)
                [ beer.name, beer.brewery, beer.style ]

        yearMatch =
            beer.year <= filters.yearMax

        countMatch =
            beer.count >= filters.countMin

        styleMatch =
            List.isEmpty filters.styles || List.member beer.style filters.styles

        locationsMatch =
            case beer.location of
                Nothing ->
                    List.isEmpty filters.locations

                Just location ->
                    List.isEmpty filters.locations || List.member location filters.locations
    in
        textMatch && yearMatch && styleMatch && countMatch && locationsMatch
