module Model.Filter exposing (..)

import Model.Beer exposing (Beer)


type FilterValue
    = OlderThan String
    | TextMatches String


type alias Filters =
    { textMatch : String
    , olderThan : Int
    , yearRange : ( Int, Int )
    }
