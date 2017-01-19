module Messages exposing (Msg(..))

import Model.Tab exposing (Tab)
import Model.Beer exposing (Beer)
import Model.NewBeerForm exposing (AddBeerInput)
import Http


type Msg
    = RetrievedBeerList (Result Http.Error (List Beer))
    | ChangeTab Tab
      -- Filter
    | UpdateFilterText String
    | UpdateFilterAge String
      -- BeerList
    | IncrementBeerCount Beer
    | DecrementBeerCount Beer
      -- AddBeerForm
    | UpdateAddBeerInput AddBeerInput
    | SubmitAddBeer
    | ClearAddBeer
