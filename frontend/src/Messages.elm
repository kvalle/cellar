module Messages exposing (Msg(..))

import Messages.BeerForm exposing (Field, SuggestionMsg)
import Model.Filters exposing (FilterValue)
import Model.Beer exposing (Beer)
import Model.Auth exposing (UserData)
import Http
import Table


type Msg
    = Noop
      -- Filter
    | ClearFilters
    | UpdateFilters FilterValue
    | ShowFilters
    | HideFilters
      -- Beer list
    | SaveBeers
    | SavedBeerList (Result Http.Error (List Beer))
    | LoadBeers
    | LoadedBeerList (Result Http.Error (List Beer))
    | IncrementBeer Beer
    | DecrementBeer Beer
    | DeleteBeer Beer
    | SetTableState Table.State
      -- Beer form
    | ShowForm Beer
    | HideForm
    | UpdateFormInput Field String
    | UpdateFormSuggestions Field SuggestionMsg
    | SubmitForm
      -- Json
    | ShowJsonModal
    | HideJsonModal
      -- Authentication
    | Login
    | LoginResult UserData
    | Logout
    | LogoutResult ()
