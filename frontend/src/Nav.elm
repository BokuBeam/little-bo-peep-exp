module Nav exposing (..)

import Articles exposing (Articles)
import Assets
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Mark
import Mark.Error


type alias Nav =
    { state : NavState
    , entries : List NavEntry
    }


type alias NavMsg msg =
    { openMsg : msg
    , closeMsg : msg
    }


type alias NavEntry =
    { title : String
    , url : String
    }


type NavState
    = Open
    | Closed


open : Nav -> Nav
open nav =
    { nav | state = Open }


close : Nav -> Nav
close nav =
    { nav | state = Closed }


fromArticles : Articles -> Nav
fromArticles articles =
    { state = Closed
    , entries =
        Articles.toList articles
            |> List.map
                (\( url, article ) ->
                    { title = parse article
                    , url = "/article/" ++ url
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


view : NavMsg msg -> Nav -> Html msg
view { openMsg, closeMsg } nav =
    case nav.state of
        Open ->
            Html.div [ Attr.class "z-50 fixed right-0 flex self-start" ]
                [ button closeMsg
                , Html.div
                    [ Attr.class "h-screen z-50 p-4"
                    , Attr.class "bg-stone-100 h-full"
                    ]
                    [ Html.ul [] <| List.map viewEntry nav.entries ]
                ]

        Closed ->
            button openMsg


button : msg -> Html msg
button msg =
    Html.button
        [ Attr.class "grow-0 m-3 flex items-center justify-center h-8 w-9 bg-teal-200 rounded"
        , onClick msg
        ]
        [ Html.img [ Attr.src <| Assets.image "hamburger.svg" ] [] ]


viewEntry : NavEntry -> Html msg
viewEntry entry =
    Html.li [] [ Html.a [ Attr.href entry.url ] [ Html.text entry.title ] ]
