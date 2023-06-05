module Main exposing (main)

import Article
import Browser
import Header
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Icon


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


type alias Model =
    { source : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { source = Nothing }
    , Http.get
        { url = "/articles/ch_1.emu"
        , expect = Http.expectString GotArticle
        }
    )



-- UPDATE


type Msg
    = GotArticle (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticle result ->
            case result of
                Ok src ->
                    ( { model | source = Just src }
                    , Cmd.none
                    )

                Err err ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Little Bo Peep"
    , body =
        [ Html.div
            [ Attr.class "w-full"
            ]
            [ Header.view
            , Article.view model.source
            ]
        ]
    }
