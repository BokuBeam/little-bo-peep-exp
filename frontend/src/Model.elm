module Model exposing (..)

import Articles exposing (Articles)
import Browser.Navigation
import Msg exposing (Msg(..))
import Page exposing (Page)
import Url exposing (Url)


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
