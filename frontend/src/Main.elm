port module Main exposing (main)

import Article
import Browser
import Header
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Http
import Msg exposing (Msg(..))


port onLoad : () -> Cmd msg


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


type alias Model =
    { article : Maybe String
    , thoughtShowing : Bool
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { article = Nothing
      , thoughtShowing = False
      }
    , Http.get
        { url = "/articles/ch_1.emu"
        , expect = Http.expectString GotArticle
        }
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticle result ->
            case result of
                Ok src ->
                    ( { model | article = Just src }
                    , onLoad ()
                    )

                Err _ ->
                    ( model, Cmd.none )

        ShowThought ->
            ( { model | thoughtShowing = True }, Cmd.none )

        HideThought ->
            ( { model | thoughtShowing = False }, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Little Bo Peep"
    , body =
        [ Html.div
            [ Attr.class "w-full" ]
            [ Header.view
            , case model.article of
                Just article ->
                    Article.view
                        { article = article
                        , thoughtShowing = model.thoughtShowing
                        }

                Nothing ->
                    Html.span [] []
            ]
        ]
    }
