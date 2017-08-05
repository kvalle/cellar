module Model.Environment exposing (..)


type Environment
    = Test
    | Dev
    | Prod
    | Local
    | Unknown


fromLocation : String -> Environment
fromLocation location =
    if String.contains "localhost" location then
        Local
    else if String.contains "test.cellar.kjetilvalle.com" location then
        Test
    else if String.contains "dev.cellar.kjetilvalle.com" location then
        Dev
    else if String.contains "cellar.kjetilvalle.com" location then
        Prod
    else
        Unknown
