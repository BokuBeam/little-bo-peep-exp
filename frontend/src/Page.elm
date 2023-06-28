module Page exposing (Page(..), fromUrl)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, string, top)


type Page
    = Home
    | Article String
    | NotFound


pageParser : Parser (Page -> a) a
pageParser =
    oneOf
        [ map Home top
        , map Article string
        ]


fromUrl : Url -> Page
fromUrl url =
    parse pageParser url |> Maybe.withDefault NotFound
