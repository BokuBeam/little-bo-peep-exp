module Msg exposing (Msg(..))

import Http


type Msg
    = GotArticle (Result Http.Error String)
    | ShowThought
    | HideThought
