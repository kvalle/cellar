module Beer exposing (Beer)


type alias Beer =
    { id : Maybe Int
    , brewery : String
    , name : String
    , style : String
    , year : Int
    , count : Int
    }
