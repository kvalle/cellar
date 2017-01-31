module Model.Filter exposing (FilterValue(..), Filters, empty)


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


empty : Filters
empty =
    Filters "" 0 [] ( 0, 0 ) False
