module Messages exposing (Msg(..))

import Messages.BeerForm exposing (Field, SuggestionMsg)
import Model.Filters exposing (FilterValue)
import Model.Beer exposing (Beer)
import Model.Auth exposing (UserData)
import Http
import Table
import Keyboard


type Msg
    = Noop
    | KeyPressed Keyboard.KeyCode
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
    | UpdateFormField Field String
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
