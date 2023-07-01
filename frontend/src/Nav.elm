module Nav exposing (..)

import Articles exposing (Articles)
import Html exposing (Html)
import Html.Attributes as Attr
import Mark
import Mark.Error


type alias Nav =
    { state : NavState
    , entries : List NavEntry
    }


type alias NavEntry =
    { title : String
    , url : String
    }


type NavState
    = Open
    | Closed


fromArticles : Articles -> Nav
fromArticles articles =
    { state = Closed
    , entries =
        Articles.toList articles
            |> List.map
                (\( url, article ) ->
                    { title = parse article
                    , url = url
                    }
                )
    }


parse : String -> String
parse article =
    case Mark.compile document article of
        Mark.Success title ->
            title

        Mark.Almost { result, errors } ->
            result

        Mark.Failure errors ->
            List.map Mark.Error.toString errors |> String.concat


document : Mark.Document String
document =
    Mark.documentWith
        (\title body ->
            title
        )
        { metadata =
            Mark.record "Article" (\title -> title)
                |> Mark.field "title" Mark.string
                |> Mark.toBlock
        , body =
            Mark.manyOf
                [ Mark.block "Paragraph" identity Mark.string
                , Mark.block "ParagraphFlat" identity Mark.string
                ]
        }


metadata : Mark.Block { title : String }
metadata =
    Mark.record "Article"
        (\title ->
            { title = title
            }
        )
        |> Mark.field "title" Mark.string
        |> Mark.toBlock


view : Nav -> Html msg
view nav =
    Html.div
        [ Attr.class "fixed right-0 z-50 p-4"
        , Attr.class "bg-stone-100 h-full"
        ]
        [ Html.ul [] <| List.map viewEntry nav.entries ]


viewEntry : NavEntry -> Html msg
viewEntry entry =
    Html.li [] [ Html.a [ Attr.href entry.url ] [ Html.text entry.title ] ]
