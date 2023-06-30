module Page exposing (Page(..), fromUrl, showArticle, showSideRight)

import Article exposing (ArticleState(..))
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


type Page
    = Home
    | Article ArticleState String
    | Error String


pageParser : Parser (Page -> a) a
pageParser =
    oneOf
        [ map Home top
        , map (Article Article.ShowArticle) <| s "article" </> string
        ]


fromUrl : Url -> Page
fromUrl url =
    parse pageParser url |> Maybe.withDefault (Error "No page found at that URL")


showArticle : Page -> Page
showArticle page =
    case page of
        Home ->
            page

        Article _ article ->
            Article ShowArticle article

        Error _ ->
            page


showSideRight : Page -> Page
showSideRight page =
    case page of
        Home ->
            page

        Article _ article ->
            Article ShowSideRight article

        Error _ ->
            page
