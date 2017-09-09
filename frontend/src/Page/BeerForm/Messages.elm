module Page.BeerForm.Messages exposing (..)

import Data.Beer exposing (Beer)


type Msg
    = UpdateFormField Field String
    | UpdateFormSuggestions Field SuggestionMsg
    | SubmitForm
    | CancelForm
    | FormSaved (Result String (List Beer))


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
