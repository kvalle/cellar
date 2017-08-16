module Route exposing (Route(..), fromLocation, href, modifyUrl)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)
import Auth0.UrlParser
    exposing
        ( Auth0CallbackInfo
        , Auth0CallbackError
        , accessTokenUrlParser
        , unauthorizedUrlParser
        )


-- ROUTING --


type Route
    = Home
    | BeerList
    | About
    | AccessTokenRoute Auth0CallbackInfo
    | UnauthorizedRoute Auth0CallbackError
    | Unknown


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home (s "")
        , Url.map BeerList (s "beers")
        , Url.map About (s "about")
        , Url.map AccessTokenRoute accessTokenUrlParser
        , Url.map UnauthorizedRoute unauthorizedUrlParser
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                BeerList ->
                    [ "beers" ]

                About ->
                    [ "about" ]

                UnauthorizedRoute _ ->
                    []

                AccessTokenRoute _ ->
                    []

                Unknown ->
                    []
    in
        "#/" ++ String.join "/" pieces



-- PUBLIC HELPERS --


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Route
fromLocation location =
    if String.isEmpty location.hash then
        Home
    else
        parseHash route location |> Maybe.withDefault Unknown
