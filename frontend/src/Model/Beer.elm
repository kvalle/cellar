module Model.Beer exposing (Beer, empty)


type alias Beer =
    { id : Maybe Int
    , brewery : String
    , name : String
    , style : String
    , year : Int
    , count : Int
    , location : Maybe String
    , shelf : Maybe String
    }


empty : Beer
empty =
    Beer Nothing "" "" "" 2017 1 Nothing Nothing
