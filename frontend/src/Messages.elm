module Messages exposing (Msg(..))

import Model.Beer exposing (Beer)
import Model.NewBeerForm exposing (AddBeerInput)
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
    | UpdateInput AddBeerInput
    | AddNewBeer
    | ClearNewBeerForm
