module Backend.Beers exposing (get, save)

import Http exposing (Request)
import Json.Decode as Decode
import Data.Auth exposing (Session)
import Data.Beer exposing (Beer, decoder, encoder)
import Data.Environment exposing (Environment(..))
import Json.Decode
import Json.Encode


get : Environment -> Session -> Request (List Beer)
get env userData =
    request
        "GET"
        (url env)
        Http.emptyBody
        (Json.Decode.list decoder)
        userData.token


save : Environment -> Session -> List Beer -> Request (List Beer)
save env userData beers =
    request
        "POST"
        ((url env) ++ "ssasdfas")
        (Http.jsonBody <| Json.Encode.list <| List.map encoder beers)
        (Json.Decode.list decoder)
        userData.token


url : Environment -> String
url env =
    case env of
        Prod ->
            "https://api.cellar.kjetilvalle.com/beers"

        Test ->
            "https://test.api.cellar.kjetilvalle.com/beers"

        Dev ->
            "https://dev.api.cellar.kjetilvalle.com/beers"

        Local ->
            "https://dev.api.cellar.kjetilvalle.com/beers"

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
