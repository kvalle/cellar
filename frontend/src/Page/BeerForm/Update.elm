module Page.BeerForm.Update exposing (update)

import Backend.Beers
import Data.AppState exposing (AppState)
import Data.Auth exposing (AuthStatus(..))
import Data.Beer exposing (Beer)
import Data.BeerList
import Http
import Page.BeerForm.Messages exposing (Msg(FormSaved), Msg(..), SuggestionMsg(..))
import Page.BeerForm.Model exposing (FormState(..), Model, empty, toBeer, updateField, updateSuggestions)
import Route
import Task


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
            ( { model | state = Saving, error = Nothing }
            , Task.attempt FormSaved <| saveBeer appState model
            )

        CancelForm ->
            ( model, Route.modifyUrl Route.BeerList )

        FormSaved (Ok beers) ->
            ( empty beers, Route.modifyUrl Route.BeerList )

        FormSaved (Err err) ->
            ( { model | state = Editing, error = Just err }, Cmd.none )


saveBeer : AppState -> Model -> Task.Task String (List Beer)
saveBeer appState model =
    let
        loadBeers userData =
            Backend.Beers.get appState.environment userData |> Http.toTask

        updateWithBeerFromForm beers =
            Data.BeerList.addOrUpdate (toBeer model beers) beers

        saveBeers userData beers =
            Backend.Beers.save appState.environment userData beers |> Http.toTask
    in
        case appState.auth of
            LoggedIn userData ->
                loadBeers userData
                    |> Task.map updateWithBeerFromForm
                    |> Task.andThen (saveBeers userData)
                    |> Task.mapError (\_ -> "Unable to save beer :(")

            LoggedOut ->
                Task.fail "Need to be logged in to fetch beer list"
