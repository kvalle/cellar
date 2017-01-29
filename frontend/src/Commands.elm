module Commands exposing (fetchBeers, saveBeers)

import Model.Beer exposing (Beer)
import Model.Environment exposing (Environment(..))
import Messages exposing (Msg(..))
import Http
import Json.Decode as Decode
import Json.Encode as Encode


fetchBeers : Environment -> String -> Cmd Msg
fetchBeers env token =
    Http.send RetrievedBeerList (request "GET" (url env) Http.emptyBody beerListDecoder token)


saveBeers : Environment -> String -> List Beer -> Cmd Msg
saveBeers env token beers =
    let
        body =
            Encode.list <| List.map beerEncoder beers
    in
        Http.send SavedBeerList (request "POST" (url env) (Http.jsonBody body) beerListDecoder token)



-- UNEXPOSED FUNCTIONS


url : Environment -> String
url env =
    case env of
        Prod ->
            "https://api.cellar.kjetilvalle.com/beers"

        Test ->
            "https://test.api.cellar.kjetilvalle.com/beers"

        Local ->
            "http://localhost:9000/beers"

        Unknown ->
            "/api/beers"


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
