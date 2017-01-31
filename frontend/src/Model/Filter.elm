module Model.Filter exposing (FilterValue(..), Filters, init, empty, setValue, setContext, matches)

import Model.Beer exposing (Beer)


type FilterValue
    = OlderThan String
    | TextMatches String
    | Styles (List String)


type alias Filters =
    { textMatch : String
    , olderThan : Int
    , styles : List String
    , yearRange : ( Int, Int )
    , active : Bool
    }


init : Filters
init =
    Filters "" 0 [] ( 0, 0 ) False


empty : List Beer -> Filters
empty beers =
    init |> setContext beers


setValue : FilterValue -> Filters -> Filters
setValue value filters =
    case value of
        OlderThan years ->
            { filters | active = True, olderThan = String.toInt years |> Result.withDefault 0 }

        TextMatches text ->
            { filters | active = True, textMatch = text }

        Styles styles ->
            { filters | active = True, styles = styles }


setContext : List Beer -> Filters -> Filters
setContext beers filters =
    let
        lower =
            List.map .year beers |> List.minimum |> Maybe.withDefault 0

        upper =
            List.map .year beers |> List.maximum |> Maybe.withDefault 0

        newOlderThan =
            if not filters.active || filters.olderThan > upper || filters.olderThan < lower then
                upper
            else
                filters.olderThan
    in
        { filters | yearRange = ( lower, upper ), olderThan = newOlderThan }


matches : Beer -> Filters -> Bool
matches beer filters =
    let
        textMatch string =
            String.contains (String.toLower filters.textMatch) (String.toLower string)

        matchesText =
            textMatch beer.name || textMatch beer.brewery || textMatch beer.style || textMatch (toString beer.year)

        isInYearRange =
            beer.year <= filters.olderThan

        matchesStyles =
            List.isEmpty filters.styles || List.member beer.style filters.styles
    in
        matchesText && isInYearRange && matchesStyles
