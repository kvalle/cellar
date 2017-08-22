module Page.BeerList.View.Help exposing (viewHelpDialog)

import Page.BeerList.Messages as Msg exposing (Msg)
import Page.BeerList.Model exposing (Model)
import Page.BeerList.Model.State exposing (DisplayState(..))
import Page.BeerList.View.HtmlExtra exposing (onClickNoPropagation)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Markdown


content : String
content =
    """## Keyboard shortcuts

- `?` will show this dialog
- `a` will show the form for adding new beers
- `f` will show the filters dialog
- `Esc` will close open dialog
- `c` will clear the filters
- `s` will save the current changes
- `r` will reset the current changes

"""


viewHelpDialog : Model -> Html Msg
viewHelpDialog model =
    case model.state.helpDialog of
        Hidden ->
            text ""

        Visible ->
            div [ class "modal", onClick Msg.HideHelp ]
                [ div [ onClickNoPropagation Msg.ShowHelp ]
                    [ Markdown.toHtml [] content
                    ]
                ]
