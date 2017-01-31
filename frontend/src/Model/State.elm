module Model.State exposing (..)


type alias State =
    { changes : Changes
    , network : Network
    , error : Maybe String
    }


init : State
init =
    State Unchanged Idle Nothing


type Changes
    = Changed
    | Unchanged


type Network
    = Saving
    | Loading
    | Idle


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
