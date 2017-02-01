module Messages exposing (Msg(..))

import Model.Filter exposing (FilterValue)
import Model.Beer exposing (Beer)
import Model.BeerForm exposing (BeerInput)
import Model.Auth exposing (UserData)
import Http
import Table


type Msg
    = RetrievedBeerList (Result Http.Error (List Beer))
    | SavedBeerList (Result Http.Error (List Beer))
      -- Filter
    | ClearFilter
    | UpdateFilter FilterValue
      -- BeerList
    | IncrementBeer Beer
    | DecrementBeer Beer
    | DeleteBeer Beer
    | SaveBeers
    | LoadBeers
    | SetTableState Table.State
      -- Beer form
    | ShowEditBeerForm Beer
    | ShowAddBeerForm
    | HideBeerForm
    | UpdateBeerForm BeerInput
    | SubmitBeerForm
      -- Authentication
    | Login
    | LoginResult UserData
    | Logout
    | LogoutResult ()
