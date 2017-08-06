module Page.BeerList.Model.Beer exposing (Beer, empty)


type alias Beer =
    { id : Maybe Int
    , brewery : String
    , name : String
    , style : String
    , year : Int
    , count : Int
    , volume : Float
    , abv : Float
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
    , volume = 0.0
    , abv = 0.0
    , location = Nothing
    , shelf = Nothing
    }
