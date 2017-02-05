module Messages exposing (Msg(..))

import Messages.BeerForm exposing (Field, SuggestionMsg)
import Model.Filters exposing (FilterValue)
import Model.Beer exposing (Beer)
import Model.Auth exposing (UserData)
import Http
import Table


type Msg
    = RetrievedBeerList (Result Http.Error (List Beer))
    | SavedBeerList (Result Http.Error (List Beer))
    | Noop
      -- Filter
    | ClearFilters
    | UpdateFilters FilterValue
    | ShowFilters
    | HideFilters
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
    | UpdateBeerForm Field String
    | UpdateSuggestions Field SuggestionMsg
    | SubmitBeerForm
      -- Json
    | ShowJsonModal
    | HideJsonModal
      -- Authentication
    | Login
    | LoginResult UserData
    | Logout
    | LogoutResult ()
