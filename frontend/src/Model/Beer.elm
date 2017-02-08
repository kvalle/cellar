module Model.Beer exposing (Beer, empty)


type alias Beer =
    { id : Maybe Int
    , brewery : String
    , name : String
    , style : String
    , year : Int
    , count : Int
    , volume : Maybe Float
    , location : Maybe String
    , shelf : Maybe String
    }


empty : Beer
empty =
    { id = Nothing
    , brewery = ""
    , name = ""
    , style = ""
    , year = 2017
    , count = 1
    , volume = Nothing
    , location = Nothing
    , shelf = Nothing
    }
