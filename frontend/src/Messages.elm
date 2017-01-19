module Messages exposing (Msg(..))

import Model.Filter exposing (FilterValue)
import Model.Tab exposing (Tab)
import Model.Beer exposing (Beer)
import Model.NewBeerForm exposing (AddBeerInput)
import Http


type Msg
    = RetrievedBeerList (Result Http.Error (List Beer))
    | ChangeTab Tab
      -- Filter
    | ClearFilter
    | UpdateFilter FilterValue
      -- BeerList
    | IncrementBeerCount Beer
    | DecrementBeerCount Beer
      -- AddBeerForm
    | UpdateAddBeerInput AddBeerInput
    | SubmitAddBeer
    | ClearAddBeer
