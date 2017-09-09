module Data.Page exposing (ActivePage(..))


type ActivePage
    = Home
    | BeerList
    | AddBeer
    | EditBeer Int
    | Json
    | Help
    | Other
