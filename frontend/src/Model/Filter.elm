module Model.Filter exposing (..)


type FilterValue
    = OlderThan String
    | TextMatches String


type alias Filters =
    { textMatch : String
    , olderThan : String
    }


setValue : Filters -> FilterValue -> Filters
setValue filters value =
    case value of
        OlderThan years ->
            { filters | olderThan = years }

        TextMatches text ->
            { filters | textMatch = text }


setTextFilter : Filters -> String -> Filters
setTextFilter filters text =
    { filters | textMatch = text }


setOlderThan : Filters -> String -> Filters
setOlderThan filters text =
    { filters | olderThan = text }


empty : String -> Filters
empty minYear =
    Filters "" minYear
