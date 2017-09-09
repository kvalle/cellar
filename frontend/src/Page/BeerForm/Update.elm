module Page.BeerForm.Update exposing (update)

import Data.Auth exposing (AuthStatus(..))
import Data.AppState exposing (AppState)
import Page.BeerForm.Messages exposing (Msg(..), SuggestionMsg(..))
import Page.BeerForm.Model exposing (Model, empty, toBeer, updateField, updateSuggestions)
import Data.Beer exposing (Beer)
import Backend.Beers
import Task
import Http


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
            ( model
            , Task.attempt FormSaved <| saveBeer appState (toBeer model)
            )

        FormSaved (Ok beers) ->
            ( empty beers, Cmd.none )

        FormSaved (Err error) ->
            ( model, Cmd.none )


saveBeer : AppState -> Beer -> Task.Task String (List Beer)
saveBeer appState beer =
    let
        loadBeers userData =
            Backend.Beers.get appState.environment userData |> Http.toTask

        saveBeers userData beers =
            Backend.Beers.save appState.environment userData beers |> Http.toTask
    in
        case appState.auth of
            LoggedIn userData ->
                loadBeers userData
                    |> Task.map ((::) beer)
                    |> Task.andThen (saveBeers userData)
                    |> Task.mapError (\_ -> "Unable to save beer :(")

            LoggedOut ->
                Task.fail "Need to be logged in to fetch beer list"
