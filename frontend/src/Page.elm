module Page exposing (Page(..), fromUrl)

import Assets
import Http
import Msg exposing (Msg(..))
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, string, top)


type Page
    = Home
    | Article String
    | Error String


pageParser : Parser (Page -> a) a
pageParser =
    oneOf
        [ map Home top
        , map Article <| s "article" </> string
        ]


fromUrl : Url -> Page
fromUrl url =
    parse pageParser url |> Maybe.withDefault (Error "No page found at that URL")
