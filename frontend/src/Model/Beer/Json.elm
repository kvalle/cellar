module Model.Beer.Json exposing (beerEncoder, beerListEncoder, beerDecoder, beerListDecoder)

import Model.Beer exposing (Beer)
import Json.Decode as Decode
import Json.Encode as Encode


beerEncoder : Beer -> Encode.Value
beerEncoder beer =
    let
        idEncoder =
            case beer.id of
                Nothing ->
                    Encode.null

                Just val ->
                    Encode.int val
    in
        Encode.object
            [ ( "id", idEncoder )
            , ( "brewery", Encode.string beer.brewery )
            , ( "name", Encode.string beer.name )
            , ( "style", Encode.string beer.style )
            , ( "year", Encode.int beer.year )
            , ( "count", Encode.int beer.count )
            ]


beerListEncoder : List Beer -> Encode.Value
beerListEncoder beers =
    Encode.list <| List.map beerEncoder beers


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
