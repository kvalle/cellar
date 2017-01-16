module Messages exposing (Msg(..))

import Beer exposing (Beer)
import Http


type Msg
    = RetrievedBeerList (Result Http.Error (List Beer))
      -- Filter
    | UpdateFilter String
      -- BeerList
    | IncrementBeerCount Beer
    | DecrementBeerCount Beer
    | AddBeerToList Beer
      -- NewBeerForm
    | UpdateBrewery String
    | UpdateName String
    | UpdateYear String
    | UpdateStyle String
    | AddNewBeer
