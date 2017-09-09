module Page.BeerList.Messages exposing (Msg(..))

import Page.BeerList.Model.Filters exposing (FilterValue)
import Data.Beer exposing (Beer)
import Data.KeyEvent exposing (KeyEvent)
import Http
import Table
import Dom


type Msg
    = Noop
    | KeyPressed (Result String KeyEvent)
    | FocusResult (Result Dom.Error ())
    | ClearModals
      -- Filter
    | ClearFilters
    | UpdateFilters FilterValue
    | ShowFilters
    | HideFilters
      -- Beer list
    | SavedBeerList (Result Http.Error (List Beer))
      -- | SaveBeers
      -- | LoadBeers
      -- | LoadedBeerList (Result Http.Error (List Beer))
    | DeleteBeer Beer
    | SetTableState Table.State
