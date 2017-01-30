module Model.Filter exposing (..)

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
