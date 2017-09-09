module Data.Beer exposing (Beer, empty, encoder, decoder)

import Json.Decode as Decode
import Json.Encode as Encode
import Json.Decode.Pipeline as Pipeline


-- MODEL --


type alias Beer =
    { id : Maybe Int
    , brewery : String
    , name : String
    , style : String
    , year : Int
    , count : Int
    , volume : Float
    , abv : Float
    , location : Maybe String
    , shelf : Maybe String
    }


empty : Beer
empty =
    { id = Nothing
    , brewery = ""
    , name = ""
    , style = ""
    , year = 2017
    , count = 1
    , volume = 0.0
    , abv = 0.0
    , location = Nothing
    , shelf = Nothing
    }



-- SERIALIZATION --


encoder : Beer -> Encode.Value
encoder beer =
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


listEncoder : List Beer -> Encode.Value
listEncoder beers =
    Encode.list <| List.map encoder beers


decoder : Decode.Decoder Beer
decoder =
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
