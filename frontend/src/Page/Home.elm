module Page.Home exposing (view)

import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(..))
import Html exposing (..)
import Html.Attributes exposing (href, class)
import Route


-- VIEW --


view : AppState -> Html msg
view appState =
    case appState.auth of
        LoggedIn session ->
            main_ []
                [ p [] [ text <| "Hi, " ++ session.profile.username ]
                , p []
                    [ text
                        """
                        This page is still a bit under construction. I'm probably
                        going to make some sort of summary of the status
                        of how many beers are stored in the cellar, etc, here.
                        Just haven't gotten quite that far yet, so stay tuned!
                        """
                    ]
                , p []
                    [ text "For now, just head over to the "
                    , a [ Route.href Route.BeerList ] [ text "beer list page" ]
                    , text " to see the contents of your cellar."
                    ]
                ]

        LoggedOut ->
            main_ []
                [ div [ class "home-about" ]
                    [ i [ class "icon-beer" ] []
                    , p []
                        [ text
                            """
                            This is the Cellar Index. A place where—you guessed it—you
                            can keep track of the beers you keep for storage in your
                            cellar. Ever found yourself wondering if you didn't have just
                            one more bottle of that belgian barleywine you picked up last
                            year, or maybe which of those old stouts on the back of the
                            shelf are old enough to open yet? Cellar Index aims to help
                            you keep track of just those sort of things.
                            """
                        ]
                    ]
                , div [ class "home-beta" ]
                    [ i [ class "icon-floppy" ] []
                    , p []
                        [ text
                            """
                            The site is still very much in beta, and a lot of things will
                            probably change going forward. It is therefore generally
                            not possible to sign up quite yet. However, if this seems like
                            the sort of thing you might need, feel free to
                            """
                        , a [ href "mailto:kjetil.valle@gmail.com" ] [ text "pop me an email" ]
                        , text " and ask to become a beta tester."
                        ]
                    ]
                ]
