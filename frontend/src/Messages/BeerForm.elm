module Messages.BeerForm exposing (..)


type SuggestionMsg
    = Next
    | Previous
    | Select
    | Refresh
    | Clear


type Field
    = Brewery
    | Name
    | Style
    | Year
    | Count
    | Volume
    | Location
    | Shelf
