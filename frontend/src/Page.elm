module Page exposing (Page(..), cmd, fromUrl)

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


cmd : Page -> Cmd Msg
cmd page =
    case page of
        Home ->
            Cmd.none

        Article name ->
            Http.get
                { url = Assets.article name
                , expect = Http.expectString GotArticle
                }

        Error _ ->
            Cmd.none
