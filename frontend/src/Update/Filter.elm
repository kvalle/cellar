module Update.Filter exposing (setContext, setValue)

import Model.Filter exposing (Filters, FilterValue(..))
import Model.Beer exposing (Beer)


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


setValue : Filters -> FilterValue -> Filters
setValue filters value =
    case value of
        OlderThan years ->
            { filters | active = True, olderThan = String.toInt years |> Result.withDefault 0 }

        TextMatches text ->
            { filters | active = True, textMatch = text }

        Styles styles ->
            { filters | active = True, styles = styles }
