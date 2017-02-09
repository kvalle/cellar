module Model.State exposing (..)


type alias State =
    { changes : Changes
    , network : Network
    , error : Maybe String
    , jsonModal : DisplayState
    , filters : DisplayState
    , beerForm : DisplayState
    , helpDialog : DisplayState
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
    , jsonModal = Hidden
    , filters = Hidden
    , beerForm = Hidden
    , helpDialog = Hidden
    }


clearModals : State -> State
clearModals state =
    state
        |> withBeerForm Hidden
        |> withFilters Hidden
        |> withJsonModal Hidden
        |> withHelpDialog Hidden


isClearOfModals : State -> Bool
isClearOfModals state =
    List.all ((==) Hidden) [ state.jsonModal, state.filters, state.beerForm ]


withHelpDialog : DisplayState -> State -> State
withHelpDialog displayState state =
    { state | helpDialog = displayState }


withBeerForm : DisplayState -> State -> State
withBeerForm displayState state =
    { state | beerForm = displayState }


withJsonModal : DisplayState -> State -> State
withJsonModal displayState state =
    { state | jsonModal = displayState }


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
