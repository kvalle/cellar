module Commands exposing (fetchBeers, saveBeers)

import Model.Beer exposing (Beer)
import Messages exposing (Msg(..))
import Http
import Json.Decode as Decode
import Json.Encode as Encode


fetchBeers : String -> Cmd Msg
fetchBeers token =
    let
        url =
            "http://localhost:9000/api/beers"
    in
        Http.send RetrievedBeerList (request "GET" url Http.emptyBody beerListDecoder token)


saveBeers : String -> List Beer -> Cmd Msg
saveBeers token beers =
    let
        url =
            "http://localhost:9000/api/beers"

        body =
            Encode.list <| List.map beerEncoder beers
    in
        Http.send SavedBeerList (request "POST" url (Http.jsonBody body) beerListDecoder token)



-- UNEXPOSED FUNCTIONS


request : String -> String -> Http.Body -> Decode.Decoder a -> String -> Http.Request a
request method url body decoder token =
    Http.request
        { method = method
        , headers =
            [ Http.header "Content-type" "application/json"
            , Http.header "Authorization" ("Bearer " ++ token)
            ]
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


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
