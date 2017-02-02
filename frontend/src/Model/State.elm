module Model.State exposing (..)


type alias State =
    { changes : Changes
    , network : Network
    , error : Maybe String
    , jsonModal : DisplayState
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
    State Unchanged Idle Nothing Hidden


withJsonModal : DisplayState -> State -> State
withJsonModal displayState state =
    { state | jsonModal = displayState }


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
