module Page.Errored exposing (PageLoadError, pageLoadError, view)

import Html exposing (Html, div, h1, img, main_, p, text, em)
import Html.Attributes exposing (alt, class, id, tabindex)


-- MODEL --


type PageLoadError
    = PageLoadError Model


type alias Model =
    { errorMessage : String
    }


pageLoadError : String -> PageLoadError
pageLoadError errorMessage =
    PageLoadError { errorMessage = errorMessage }



-- VIEW --


view : PageLoadError -> Html msg
view (PageLoadError model) =
    main_ [ id "content", class "container", tabindex -1 ]
        [ p [] [ text "Error Loading Page" ]
        , p [] [ em [] [ text model.errorMessage ] ]
        ]
