module Messages.BeerForm exposing (BeerInput(..))


type BeerInput
    = BreweryInput String
    | NameInput String
    | StyleInput String
    | YearInput String
    | CountInput String
    | LocationInput String
    | ShelfInput String
