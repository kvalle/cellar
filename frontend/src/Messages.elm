module Messages exposing (Msg(..))

import Model.Filter exposing (FilterValue)
import Model.Tab exposing (Tab)
import Model.Beer exposing (Beer)
import Model.BeerForm exposing (BeerInput)
import Model.Auth exposing (UserData)
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
    | DeleteBeer Beer
    | SaveBeers
    | LoadBeers
      -- AddBeerForm
    | UpdateBeerForm BeerInput
    | SubmitBeerForm
    | ClearBeerForm
      -- Authentication
    | Login
    | LoginResult UserData
    | Logout
    | LogoutResult ()
