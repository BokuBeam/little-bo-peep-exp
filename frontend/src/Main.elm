module Main exposing (main)

import Article
import Browser
import Browser.Navigation
import Header
import Home
import Html
import Html.Attributes as Attr
import Http
import Msg exposing (Msg(..))
import NotFound
import Page exposing (Page)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


type alias Model =
    { page : Page
    , thoughtShowing : Bool
    , key : Browser.Navigation.Key
    , url : Url
    }


init : () -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init () url key =
    let
        page =
            Page.fromUrl url
    in
    ( { page = page
      , thoughtShowing = False
      , key = key
      , url = url
      }
    , Http.get
        { url = "api/articles"
        , expect = Http.expectString GotArticle
        }
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl model.key
                        (Url.toString url)
                    )

                Browser.External href ->
                    ( model, Browser.Navigation.load href )

        GotArticle result ->
            case result of
                Ok src ->
                    ( { model | page = Page.Article src }
                    , Cmd.none
                    )

                Err error ->
                    let
                        errorString =
                            case error of
                                Http.BadUrl s ->
                                    s

                                Http.Timeout ->
                                    "Request timed out"

                                Http.NetworkError ->
                                    "Network error"

                                Http.BadStatus status ->
                                    "Bad status: " ++ String.fromInt status

                                Http.BadBody body ->
                                    "Bad body: " ++ body
                    in
                    ( { model | page = Page.Error errorString }, Cmd.none )

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
            , Html.div [ Attr.class "pt-14 lg:pt-20" ]
                [ case model.page of
                    Page.Home ->
                        Home.view

                    Page.Article article ->
                        Article.view
                            { article = article
                            , thoughtShowing = model.thoughtShowing
                            }

                    Page.Error error ->
                        NotFound.view error
                ]
            ]
        ]
    }
