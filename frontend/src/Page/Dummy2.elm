module Page.Dummy2 exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder)
import Html.Events exposing (onClick)
import Http
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Task exposing (Task)


-- MODEL --


type alias Model =
    String


init : Task PageLoadError Model
init =
    Task.succeed "This is dummy page 2"



-- VIEW --


view : Model -> Html Msg
view model =
    text model



-- UPDATE --


type Msg
    = IgnoreForNow


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IgnoreForNow ->
            ( model, Cmd.none )
