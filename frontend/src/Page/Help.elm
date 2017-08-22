module Page.Help exposing (view)

import Html exposing (..)
import Markdown


view : Html msg
view =
    Markdown.toHtml [] """
This here is the help page. There's not much yet, but
anyway here are some keyboard shortcuts that work on
the beer list page:

- `?` will show this dialog
- `a` will show the form for adding new beers
- `f` will show the filters dialog
- `Esc` will close open dialog
- `c` will clear the filters
- `s` will save the current changes
- `r` will reset the current changes
"""
