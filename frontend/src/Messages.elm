module Messages exposing (..)

import Beer exposing (Beer)
import Http


type Msg
    = UpdateFilter String
    | RetrievedBeerList (Result Http.Error (List Beer))
    | BeerListMessage BeerListMsg
    | AddBeerMessage AddBeerMsg


type BeerListMsg
    = DecrementBeerCount Beer
    | IncrementBeerCount Beer
    | AddBeerToList Beer


type AddBeerMsg
    = UpdateBrewery String
    | UpdateName String
    | UpdateYear String
    | UpdateStyle String
    | AddNewBeer
    | ClearForm
