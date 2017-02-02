module Messages exposing (Msg(..))

import Model.Filters exposing (FilterValue)
import Model.Beer exposing (Beer)
import Model.BeerForm exposing (BeerInput)
import Model.Auth exposing (UserData)
import Http
import Table


type Msg
    = RetrievedBeerList (Result Http.Error (List Beer))
    | SavedBeerList (Result Http.Error (List Beer))
      -- Filter
    | ClearFilters
    | UpdateFilters FilterValue
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
      -- Json
    | ShowJsonModal
    | HideJsonModal
      -- Authentication
    | Login
    | LoginResult UserData
    | Logout
    | LogoutResult ()
