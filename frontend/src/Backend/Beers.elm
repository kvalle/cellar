module Backend.Beers exposing (get, save)

import Http exposing (Request)
import Json.Decode as Decode
import Data.Auth exposing (UserData)
import Data.Beer exposing (Beer, listDecoder, listEncoder)
import Data.Environment exposing (Environment(..))


get : Environment -> UserData -> Request (List Beer)
get env userData =
    request
        "GET"
        (url env)
        Http.emptyBody
        listDecoder
        userData.token


save : Environment -> UserData -> List Beer -> Request (List Beer)
save env userData beers =
    request
        "POST"
        (url env)
        (Http.jsonBody <| listEncoder beers)
        listDecoder
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
