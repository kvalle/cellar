module Route exposing (Route(..), fromLocation, href, modifyUrl)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)


-- ROUTING --


type Route
    = BeerList
    | About
    | AuthRedirect String


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map BeerList Url.top
        , Url.map About (s "about")
        , Url.map AuthRedirect authRedirectParser
        ]


authRedirectParser : Parser (String -> a) a
authRedirectParser =
    Url.custom "AUTH_REDIRECT" <|
        \segment ->
            if String.startsWith "access_token=" segment then
                Ok segment
            else
                Err ""



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                BeerList ->
                    []

                About ->
                    [ "about" ]

                AuthRedirect _ ->
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


fromLocation : Location -> Maybe Route
fromLocation location =
    let
        _ =
            Debug.log "Location is" location
    in
        if String.isEmpty location.hash then
            Just BeerList
        else
            parseHash route location
