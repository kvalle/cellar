module Messages.BeerForm exposing (..)


type SuggestionMsg
    = Next
    | Previous
    | Select
    | Refresh


type Field
    = Brewery
    | Name
    | Style
    | Year
    | Count
    | Location
    | Shelf
