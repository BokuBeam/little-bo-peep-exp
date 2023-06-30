module Msg exposing (Msg(..))

import Articles exposing (Articles)
import Browser
import Http
import Url exposing (Url)


type Msg
    = ShowThought
    | HideThought
    | UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | GotArticles (Result Http.Error Articles)
