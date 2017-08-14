module Data.Environment exposing (..)


type Environment
    = Test
    | Dev
    | Prod
    | Local
    | Unknown


fromHostString : String -> Environment
fromHostString host =
    if String.contains "localhost" host then
        Local
    else if String.contains "test.cellar.kjetilvalle.com" host then
        Test
    else if String.contains "dev.cellar.kjetilvalle.com" host then
        Dev
    else if String.contains "cellar.kjetilvalle.com" host then
        Prod
    else
        Unknown
