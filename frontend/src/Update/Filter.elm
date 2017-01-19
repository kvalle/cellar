module Update.Filter exposing (updateLimits, setValue, empty)

import Model.Filter exposing (Filters, FilterValue(..))
import Model.Beer exposing (Beer)


empty : Filters
empty =
    Filters "" 0 ( 0, 0 )


updateLimits : List Beer -> Filters -> Filters
updateLimits beers filters =
    let
        lower =
            List.map .year beers |> List.minimum |> Maybe.withDefault 0

        upper =
            List.map .year beers |> List.maximum |> Maybe.withDefault 0

        newOlderThan =
            if filters.olderThan > upper || filters.olderThan < lower then
                upper
            else
                filters.olderThan
    in
        { filters | yearRange = ( lower, upper ), olderThan = newOlderThan }


setValue : Filters -> FilterValue -> Filters
setValue filters value =
    case value of
        OlderThan years ->
            { filters | olderThan = String.toInt years |> Result.withDefault 0 }

        TextMatches text ->
            { filters | textMatch = text }
