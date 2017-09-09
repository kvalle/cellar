module Route exposing (Route(..), fromLocation, href, modifyUrl, fromName, toName, fromActivePage)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string, int)
import Data.Page
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
    | AddBeer
    | EditBeer Int
    | Json
    | Help
    | AccessTokenRoute Auth0CallbackInfo
    | UnauthorizedRoute Auth0CallbackError
    | Unknown


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home (s "")
        , Url.map BeerList (s "beers")
        , Url.map AddBeer (s "beers" </> s "add")
        , Url.map EditBeer (s "beers" </> s "edit" </> int)
        , Url.map Json (s "json")
        , Url.map Help (s "help")
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

                AddBeer ->
                    [ "beers", "add" ]

                EditBeer id ->
                    [ "beers", "edit", toString id ]

                Json ->
                    [ "json" ]

                Help ->
                    [ "help" ]

                UnauthorizedRoute _ ->
                    []

                AccessTokenRoute _ ->
                    []

                Unknown ->
                    []
    in
        "#/" ++ String.join "/" pieces


names : List ( String, Route )
names =
    [ ( "home", Home )
    , ( "beer-list", BeerList )
    , ( "add-beer", AddBeer )
    , ( "json", Json )
    ]



-- PUBLIC HELPERS --


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Route
fromLocation location =
    let
        _ =
            Debug.log "Location changed: " location
    in
        if String.isEmpty location.hash then
            Home
        else
            parseHash route location |> Maybe.withDefault Unknown


fromName : String -> Route
fromName name =
    names
        |> List.filter (Tuple.first >> (==) name)
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault Unknown


toName : Route -> String
toName route =
    names
        |> List.filter (Tuple.second >> (==) route)
        |> List.head
        |> Maybe.map Tuple.first
        |> Maybe.withDefault ""


fromActivePage : Data.Page.ActivePage -> Route
fromActivePage activePage =
    case activePage of
        Data.Page.Home ->
            Home

        Data.Page.BeerList ->
            BeerList

        Data.Page.AddBeer ->
            AddBeer

        Data.Page.EditBeer id ->
            EditBeer id

        Data.Page.Json ->
            Json

        Data.Page.Help ->
            Help

        Data.Page.Other ->
            Unknown
