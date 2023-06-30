module Main exposing (main)

import Article
import Articles
import Browser
import Browser.Navigation
import Header
import Home
import Html
import Html.Attributes as Attr
import Model exposing (Model(..))
import Msg exposing (Msg(..))
import NotFound
import Page
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


init : () -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Loading { key = key, url = url }
    , Articles.get GotArticles
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( Loading urlData, GotArticles result ) ->
            case result of
                Ok articles ->
                    ( Loaded urlData
                        { articles = articles
                        , page = Page.fromUrl urlData.url
                        , thoughtShowing = False
                        }
                    , Cmd.none
                    )

                Err error ->
                    ( Error urlData, Cmd.none )

        ( m, UrlChanged url ) ->
            ( Model.updateUrl url m
            , Cmd.none
            )

        ( m, LinkClicked urlRequest ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl (Model.getKey m)
                        (Url.toString url)
                    )

                Browser.External href ->
                    ( model, Browser.Navigation.load href )

        ( Loaded urlData data, ShowThought ) ->
            ( Loaded urlData { data | thoughtShowing = True }, Cmd.none )

        ( Loaded urlData data, HideThought ) ->
            ( Loaded urlData { data | thoughtShowing = False }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model of
        Loading _ ->
            { title = "Little Bo Peep | Loading"
            , body = [ Html.div [] [ Html.text "Loading" ] ]
            }

        Loaded _ data ->
            { title = "Little Bo Peep"
            , body =
                [ Html.div
                    [ Attr.class "w-full" ]
                    [ Header.view
                    , Html.div [ Attr.class "pt-14 lg:pt-20" ]
                        [ case data.page of
                            Page.Home ->
                                Home.view

                            Page.Article article ->
                                Article.view
                                    { article = article
                                    , thoughtShowing = data.thoughtShowing
                                    }

                            Page.Error error ->
                                NotFound.view error
                        ]
                    ]
                ]
            }

        Error _ ->
            { title = "Litte Bo Beep | Error"
            , body = [ Html.div [] [ Html.text "Error" ] ]
            }
