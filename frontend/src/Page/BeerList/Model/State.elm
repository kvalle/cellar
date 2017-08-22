module Page.BeerList.Model.State exposing (..)


type alias State =
    { changes : Changes
    , network : Network
    , error : Maybe String
    , filters : DisplayState
    , beerForm : DisplayState
    }


type Changes
    = Changed
    | Unchanged


type Network
    = Saving
    | Loading
    | Idle


type DisplayState
    = Hidden
    | Visible


init : State
init =
    { changes = Unchanged
    , network = Idle
    , error = Nothing
    , filters = Hidden
    , beerForm = Hidden
    }


clearModals : State -> State
clearModals state =
    state
        |> withBeerForm Hidden
        |> withFilters Hidden


isClearOfModals : State -> Bool
isClearOfModals state =
    List.all ((==) Hidden) [ state.filters, state.beerForm ]


withBeerForm : DisplayState -> State -> State
withBeerForm displayState state =
    { state | beerForm = displayState }


withFilters : DisplayState -> State -> State
withFilters displayState state =
    { state | filters = displayState }


withError : String -> State -> State
withError msg state =
    { state | error = Just msg }


withNoError : State -> State
withNoError state =
    { state | error = Nothing }


withNetwork : Network -> State -> State
withNetwork network state =
    { state | network = network }


withChanges : State -> State
withChanges state =
    { state | changes = Changed }


withNoChanges : State -> State
withNoChanges state =
    { state | changes = Unchanged }
