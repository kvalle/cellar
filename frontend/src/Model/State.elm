module Model.State exposing (..)


type Changes
    = Changed
    | Unchanged


type Network
    = Saving
    | Loading
    | Idle
