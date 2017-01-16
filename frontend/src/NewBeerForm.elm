module NewBeerForm exposing (..)


empty : NewBeerForm
empty =
    NewBeerForm "" "" "" "" Nothing


type alias NewBeerForm =
    { brewery : String
    , name : String
    , style : String
    , year : String
    , error : Maybe String
    }
