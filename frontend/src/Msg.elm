module Msg exposing (Msg(..))

import Browser
import Http
import Url exposing (Url)


type Msg
    = GotArticle (Result Http.Error String)
    | ShowThought
    | HideThought
    | UrlChanged Url
    | LinkClicked Browser.UrlRequest
