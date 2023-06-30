module Nav exposing (..)

import Articles exposing (Articles)
import Html exposing (Html)
import Html.Attributes as Attr


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
                    { title = url
                    , url = url
                    }
                )
    }


view : Nav -> Html msg
view nav =
    Html.div
        [ Attr.class "fixed right-0 z-50"
        , Attr.class "bg-stone-300 h-full"
        ]
        [ Html.ul [] <| List.map viewEntry nav.entries ]


viewEntry : NavEntry -> Html msg
viewEntry entry =
    Html.li [] [ Html.text entry.title ]
