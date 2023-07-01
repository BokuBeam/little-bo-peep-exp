module Main exposing (main)

import Article
import Articles exposing (Articles)
import Browser
import Browser.Navigation
import Header
import Home
import Html
import Html.Attributes as Attr
import Http
import Nav exposing (Nav)
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



-- MODEL


type Model
    = Loading UrlData
    | Loaded UrlData PageData
    | Error UrlData


type alias UrlData =
    { key : Browser.Navigation.Key
    , url : Url
    }


type alias PageData =
    { page : Page
    , articles : Articles
    , nav : Nav
    }


updateUrl : Url -> Model -> Model
updateUrl url model =
    case model of
        Loading urlData ->
            Loading { urlData | url = url }

        Loaded urlData data ->
            Loaded { urlData | url = url } data

        Error urlData ->
            Error { urlData | url = url }


getKey : Model -> Browser.Navigation.Key
getKey model =
    case model of
        Loading urlData ->
            urlData.key

        Loaded urlData _ ->
            urlData.key

        Error urlData ->
            urlData.key



-- UPDATE


type Msg
    = ShowRightSide
    | ShowArticle
    | UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | GotArticles (Result Http.Error Articles)


init : () -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Loading { key = key, url = url }
    , Articles.request GotArticles
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( Loading urlData, GotArticles result ) ->
            case result of
                Ok articles ->
                    ( Loaded urlData
                        { articles = articles
                        , page = Page.fromUrl urlData.url
                        , nav = Nav.fromArticles articles
                        }
                    , Cmd.none
                    )

                Err error ->
                    ( Error urlData, Cmd.none )

        ( Loaded urlData data, UrlChanged url ) ->
            ( Loaded
                { urlData | url = url }
                { data | page = Page.fromUrl url }
            , Cmd.none
            )

        ( m, LinkClicked urlRequest ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl (getKey m)
                        (Url.toString url)
                    )

                Browser.External href ->
                    ( model, Browser.Navigation.load href )

        ( Loaded urlData data, ShowRightSide ) ->
            ( Loaded urlData { data | page = Page.showSideRight data.page }, Cmd.none )

        ( Loaded urlData data, ShowArticle ) ->
            ( Loaded urlData { data | page = Page.showArticle data.page }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model of
        Loading _ ->
            { title = "Little Bo Peep"
            , body = [ Html.div [] [ Html.text "Loading" ] ]
            }

        Loaded _ data ->
            { title = "Little Bo Peep"
            , body =
                [ Html.div
                    [ Attr.class "w-full" ]
                    [ Header.view
                    , Nav.view data.nav
                    , Html.div [ Attr.class "pt-14 lg:pt-20" ]
                        [ case data.page of
                            Page.Home ->
                                Home.view

                            Page.Article articleState articleKey ->
                                Articles.get articleKey data.articles
                                    |> Maybe.map
                                        (\article ->
                                            Article.view
                                                { article = article
                                                , articleState = articleState
                                                , hideThoughtMsg = ShowArticle
                                                , showThoughtMsg = ShowRightSide
                                                }
                                        )
                                    |> Maybe.withDefault
                                        (NotFound.view "No article found at that address.")

                            Page.Error error ->
                                NotFound.view error
                        ]
                    ]
                ]
            }

        Error _ ->
            { title = "Little Bo Beep"
            , body = [ Html.div [] [ Html.text "Error" ] ]
            }
