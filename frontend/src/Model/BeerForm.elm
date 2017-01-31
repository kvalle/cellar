module Model.BeerForm exposing (..)


type BeerInput
    = BreweryInput String
    | NameInput String
    | StyleInput String
    | YearInput String


type alias BeerFormField =
    { value : String
    , error : Maybe String
    }


type alias BeerForm =
    { brewery : BeerFormField
    , name : BeerFormField
    , style : BeerFormField
    , year : BeerFormField
    , submitted : Bool
    }


empty : BeerForm
empty =
    BeerForm
        { value = "", error = Nothing }
        { value = "", error = Nothing }
        { value = "", error = Nothing }
        { value = "", error = Nothing }
        False
