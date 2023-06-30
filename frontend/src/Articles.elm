module Articles exposing (..)

import Dict exposing (Dict)
import Http
import Json.Decode as Decode exposing (Decoder)


type Articles
    = Articles (Dict String String)


request : (Result Http.Error Articles -> msg) -> Cmd msg
request msg =
    Http.get
        { url = "/api/articles"
        , expect = Http.expectJson msg decodeArticles
        }


decodeArticles : Decoder Articles
decodeArticles =
    Decode.dict Decode.string |> Decode.map Articles


get : String -> Articles -> Maybe String
get key (Articles dict) =
    Dict.get key dict


toList : Articles -> List ( String, String )
toList (Articles articles) =
    Dict.toList articles
