module Home exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Nav exposing (Nav)
import Styles


view : Nav -> Html msg
view nav =
    Html.div [ Attr.class "font-baskerville text-3xl w-full absolute flex justifly-center align-center" ]
        [ Html.div
            [ Attr.class "w-full md:w-192 lg:w-full"
            ]
            [ Html.div [ Attr.class Styles.largeGrid ]
                [ Html.div [ Attr.class "lg:col-start-2 p-4" ]
                    [ Html.h1 [ Attr.class "text-4xl pb-10" ] [ Html.text "Chapters" ]
                    , Nav.viewList nav
                    ]
                ]
            ]
        ]
