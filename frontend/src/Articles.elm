module Articles exposing (Articles, get)

import Dict exposing (Dict)
import Http
import Json.Decode exposing (Decoder, dict, string)


type alias Articles =
    Dict String String


get : (Result Http.Error Articles -> msg) -> Cmd msg
get msg =
    Http.get
        { url = "/api/articles"
        , expect = Http.expectJson msg decodeArticles
        }


decodeArticles : Decoder Articles
decodeArticles =
    dict string
