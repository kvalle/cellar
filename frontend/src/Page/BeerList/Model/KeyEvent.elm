module Page.BeerList.Model.KeyEvent exposing (KeyEvent, fromKeyCode, keys, keyEventDecoder)

import Json.Decode
import Json.Decode.Pipeline as Pipeline


type alias KeyEvent =
    { key : Int
    , ctrl : Bool
    , shift : Bool
    , alt : Bool
    , meta : Bool
    }


fromKeyCode : Int -> KeyEvent
fromKeyCode code =
    KeyEvent code False False False False


keyEventDecoder : Json.Decode.Decoder KeyEvent
keyEventDecoder =
    Pipeline.decode KeyEvent
        |> Pipeline.required "keyCode" Json.Decode.int
        |> Pipeline.required "ctrlKey" Json.Decode.bool
        |> Pipeline.required "shiftKey" Json.Decode.bool
        |> Pipeline.required "altKey" Json.Decode.bool
        |> Pipeline.required "metaKey" Json.Decode.bool


keys :
    { arrowDown : KeyEvent
    , arrowUp : KeyEvent
    , enter : KeyEvent
    , escape : KeyEvent
    , questionMark : KeyEvent
    , tab : KeyEvent
    , a : KeyEvent
    , f : KeyEvent
    , j : KeyEvent
    , c : KeyEvent
    , s : KeyEvent
    , r : KeyEvent
    }
keys =
    { arrowDown = fromKeyCode 40
    , arrowUp = fromKeyCode 38
    , enter = fromKeyCode 13
    , questionMark = fromKeyCode 191
    , escape = fromKeyCode 27
    , tab = fromKeyCode 8
    , a = fromKeyCode 65
    , f = fromKeyCode 70
    , j = fromKeyCode 74
    , c = fromKeyCode 67
    , s = fromKeyCode 83
    , r = fromKeyCode 82
    }
