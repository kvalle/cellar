module Page.BeerForm.Update exposing (update)

import Data.AppState exposing (AppState)
import Page.BeerForm.Messages exposing (Msg(..), SuggestionMsg(..))
import Page.BeerForm.Model exposing (Model, updateField, updateSuggestions)


update : Msg -> AppState -> Model -> ( Model, Cmd Msg )
update msg appState model =
    case msg of
        UpdateFormField field input ->
            ( model
                |> updateField field input
                |> updateSuggestions field Refresh
            , Cmd.none
            )

        UpdateFormSuggestions field msg ->
            ( model |> updateSuggestions field msg
            , Cmd.none
            )

        SubmitForm ->
            ( -- FIXME: clear form
              model
            , -- FIXME: save the beer
              Cmd.none
            )
