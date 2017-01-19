module Messages exposing (Msg(..))

import Model.Filter exposing (FilterValue)
import Model.Tab exposing (Tab)
import Model.Beer exposing (Beer)
import Model.BeerForm exposing (BeerInput)
import Http


type Msg
    = RetrievedBeerList (Result Http.Error (List Beer))
    | SavedBeerList (Result Http.Error (List Beer))
    | ChangeTab Tab
      -- Filter
    | ClearFilter
    | UpdateFilter FilterValue
      -- BeerList
    | IncrementBeer Beer
    | DecrementBeer Beer
    | SaveBeers
      -- AddBeerForm
    | UpdateBeerForm BeerInput
    | SubmitBeerForm
    | ClearBeerForm
