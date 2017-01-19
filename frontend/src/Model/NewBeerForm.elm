module Model.NewBeerForm exposing (..)

import Model.Beer exposing (Beer)


type AddBeerInput
    = BreweryInput String
    | NameInput String
    | StyleInput String
    | YearInput String


type alias NewBeerInput =
    { value : String
    , error : Maybe String
    }


type alias NewBeerForm =
    { brewery : NewBeerInput
    , name : NewBeerInput
    , style : NewBeerInput
    , year : NewBeerInput
    , submitted : Bool
    }
