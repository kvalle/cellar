module Commands exposing (fetchBeers, saveBeers)

import Model.Beer exposing (Beer)
import Messages exposing (Msg(..))
import Http
import Json.Decode as Decode
import Json.Encode as Encode


fetchBeers : Cmd Msg
fetchBeers =
    let
        url =
            "http://localhost:9000/api/beers"
    in
        Http.send RetrievedBeerList (Http.get url beerListDecoder)


saveBeers : List Beer -> Cmd Msg
saveBeers beers =
    let
        url =
            "http://localhost:9000/api/beers"

        body =
            Encode.list <| List.map beerEncoder beers
    in
        Http.send SavedBeerList (Http.post url (Http.jsonBody body) beerListDecoder)



-- UNEXPOSED FUNCTIONS


idEncoder : Maybe Int -> Encode.Value
idEncoder id =
    case id of
        Nothing ->
            Encode.null

        Just val ->
            Encode.int val


beerEncoder : Beer -> Encode.Value
beerEncoder beer =
    Encode.object
        [ ( "id", idEncoder beer.id )
        , ( "brewery", Encode.string beer.brewery )
        , ( "name", Encode.string beer.name )
        , ( "style", Encode.string beer.style )
        , ( "year", Encode.int beer.year )
        , ( "count", Encode.int beer.count )
        ]


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
