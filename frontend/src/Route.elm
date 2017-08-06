module Route exposing (Route(..), fromLocation, href, modifyUrl)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)


-- ROUTING --


type Route
    = Dummy1
    | Dummy2
    | BeerList


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Dummy1 (s "")
        , Url.map Dummy2 (s "dummy2")
        , Url.map BeerList (s "beer")
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Dummy1 ->
                    []

                Dummy2 ->
                    [ "dummy2" ]

                BeerList ->
                    [ "beer" ]
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
    if String.isEmpty location.hash then
        Just Dummy1
    else
        parseHash route location
