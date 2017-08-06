module Page.About exposing (view)

import Html exposing (..)
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Task exposing (Task)


-- VIEW --


view : Html msg
view =
    text "This is the about page"
