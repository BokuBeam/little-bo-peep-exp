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
    | Loaded
        UrlData
        { page : Page
        , thoughtShowing : Bool
        , articles : Articles
        }
    | Error UrlData


type alias UrlData =
    { key : Browser.Navigation.Key
    , url : Url
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
    = ShowThought
    | HideThought
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
                        , thoughtShowing = False
                        }
                    , Cmd.none
                    )

                Err error ->
                    ( Error urlData, Cmd.none )

        ( m, UrlChanged url ) ->
            ( updateUrl url m
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
            { title = "Little Bo Peep"
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

                            Page.Article articleKey ->
                                Articles.get articleKey data.articles
                                    |> Maybe.map
                                        (\article ->
                                            Article.view
                                                { article = article
                                                , thoughtShowing = False
                                                , hideThoughtMsg = HideThought
                                                , showThoughtMsg = ShowThought
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
