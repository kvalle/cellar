module Model.Beer.Json exposing (beerEncoder, beerListEncoder, beerDecoder, beerListDecoder)

import Model.Beer exposing (Beer)
import Json.Decode as Decode
import Json.Encode as Encode
import Json.Decode.Pipeline as Pipeline


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
            , ( "volume", Encode.float beer.volume )
            , ( "abv", Encode.float beer.abv )
            , ( "location", maybeEncoder Encode.string beer.location )
            , ( "shelf", maybeEncoder Encode.string beer.shelf )
            ]


beerListEncoder : List Beer -> Encode.Value
beerListEncoder beers =
    Encode.list <| List.map beerEncoder beers


beerDecoder : Decode.Decoder Beer
beerDecoder =
    Pipeline.decode Beer
        |> Pipeline.required "id" (Decode.nullable Decode.int)
        |> Pipeline.required "brewery" Decode.string
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "style" Decode.string
        |> Pipeline.required "year" Decode.int
        |> Pipeline.required "count" Decode.int
        |> Pipeline.optional "volume" Decode.float 0.0
        |> Pipeline.optional "abv" Decode.float 0.0
        |> Pipeline.optional "location" (Decode.nullable Decode.string) Nothing
        |> Pipeline.optional "shelf" (Decode.nullable Decode.string) Nothing


beerListDecoder : Decode.Decoder (List Beer)
beerListDecoder =
    Decode.list beerDecoder
