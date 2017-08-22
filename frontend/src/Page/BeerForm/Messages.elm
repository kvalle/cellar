module Page.BeerForm.Messages exposing (..)


type Msg
    = UpdateFormField Field String
    | UpdateFormSuggestions Field SuggestionMsg
    | SubmitForm


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
    | Abv
    | Location
    | Shelf
