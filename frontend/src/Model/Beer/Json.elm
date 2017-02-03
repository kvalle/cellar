module Model.Beer.Json exposing (beerEncoder, beerListEncoder, beerDecoder, beerListDecoder)

import Model.Beer exposing (Beer)
import Json.Decode as Decode
import Json.Encode as Encode


beerEncoder : Beer -> Encode.Value
beerEncoder beer =
    let
        maybeEncoder encoder maybe =
            case maybe of
                Nothing ->
                    Encode.null

                Just val ->
                    encoder val
    in
        Encode.object
            [ ( "id", maybeEncoder Encode.int beer.id )
            , ( "brewery", Encode.string beer.brewery )
            , ( "name", Encode.string beer.name )
            , ( "style", Encode.string beer.style )
            , ( "year", Encode.int beer.year )
            , ( "count", Encode.int beer.count )
            , ( "location", maybeEncoder Encode.string beer.location )
            , ( "shelf", maybeEncoder Encode.string beer.shelf )
            ]


beerListEncoder : List Beer -> Encode.Value
beerListEncoder beers =
    Encode.list <| List.map beerEncoder beers


beerDecoder : Decode.Decoder Beer
beerDecoder =
    Decode.map8 Beer
        (Decode.nullable (Decode.field "id" Decode.int))
        (Decode.field "brewery" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "style" Decode.string)
        (Decode.field "year" Decode.int)
        (Decode.field "count" Decode.int)
        (Decode.maybe (Decode.field "location" Decode.string))
        (Decode.maybe (Decode.field "shelf" Decode.string))


beerListDecoder : Decode.Decoder (List Beer)
beerListDecoder =
    Decode.list beerDecoder
