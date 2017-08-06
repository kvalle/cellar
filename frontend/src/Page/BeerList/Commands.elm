module Page.BeerList.Commands exposing (fetchBeers, saveBeers)

import Page.BeerList.Model.Beer exposing (Beer)
import Page.BeerList.Model.Environment exposing (Environment(..))
import Page.BeerList.Model.Auth exposing (AuthStatus(..))
import Page.BeerList.Messages exposing (Msg(..))
import Page.BeerList.Model.Beer.Json exposing (beerListEncoder, beerListDecoder)
import Http
import Json.Decode as Decode


fetchBeers : Environment -> AuthStatus -> Cmd Msg
fetchBeers env auth =
    case auth of
        LoggedIn userData ->
            Http.send
                LoadedBeerList
                (request
                    "GET"
                    (url env)
                    Http.emptyBody
                    beerListDecoder
                    userData.token
                )

        _ ->
            Cmd.none


saveBeers : Environment -> AuthStatus -> List Beer -> Cmd Msg
saveBeers env auth beers =
    case auth of
        LoggedIn userData ->
            Http.send
                SavedBeerList
                (request
                    "POST"
                    (url env)
                    (Http.jsonBody <| beerListEncoder beers)
                    beerListDecoder
                    userData.token
                )

        _ ->
            Cmd.none


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
