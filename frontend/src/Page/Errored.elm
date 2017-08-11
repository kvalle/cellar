module Page.Errored exposing (PageLoadError, pageLoadError, view, getActivePage)

import Html exposing (Html, div, h1, img, main_, p, text, em)
import Views.Page exposing (ActivePage)


-- MODEL --


type PageLoadError
    = PageLoadError Model


type alias Model =
    { activePage : ActivePage
    , errorMessage : String
    }


pageLoadError : ActivePage -> String -> PageLoadError
pageLoadError activePage errorMessage =
    PageLoadError { activePage = activePage, errorMessage = errorMessage }


getActivePage : PageLoadError -> ActivePage
getActivePage (PageLoadError model) =
    model.activePage



-- VIEW --


view : PageLoadError -> Html msg
view (PageLoadError model) =
    div []
        [ p [] [ text "Error Loading Page" ]
        , p [] [ em [] [ text model.errorMessage ] ]
        ]
