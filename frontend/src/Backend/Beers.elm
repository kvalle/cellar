module Backend.Beers exposing (get)

import Http exposing (Request)
import Json.Decode as Decode
import Page.BeerList.Model.Auth exposing (UserData)
import Page.BeerList.Model.Beer exposing (Beer)
import Page.BeerList.Model.Beer.Json exposing (beerListDecoder, beerListEncoder)
import Data.Environment exposing (Environment(..))


get : Environment -> UserData -> Request (List Beer)
get env userData =
    request
        "GET"
        (url env)
        Http.emptyBody
        beerListDecoder
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
