module Commands exposing (fetchBeerList)

import Model.Beer exposing (Beer)
import Messages exposing (Msg(..))
import Http
import Json.Decode as Decode


fetchBeerList : Cmd Msg
fetchBeerList =
    let
        url =
            "http://localhost:9000/api/beers"
    in
        Http.send RetrievedBeerList (Http.get url beerListDecoder)


beerDecoder : Decode.Decoder Beer
beerDecoder =
    Decode.map6 Beer
        (Decode.nullable (Decode.field "id" Decode.int))
        (Decode.field "brewery" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "style" Decode.string)
        (Decode.field "year" Decode.int)
        (Decode.field "count" Decode.int)


beerListDecoder : Decode.Decoder (List Beer)
beerListDecoder =
    Decode.list beerDecoder
