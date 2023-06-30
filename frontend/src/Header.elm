module Header exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Styles


view : Html msg
view =
    Html.div
        [ Attr.class "flex justify-center items-center"
        , Attr.class "fixed lg:absolute w-full bg-white z-50"
        , Attr.class "border-b-2 border-t-10"
        , Attr.class "h-14"
        ]
        [ Html.div
            [ Attr.class "w-full md:w-192 lg:w-full pl-4"
            , Attr.class Styles.largeGrid
            , Attr.id "Header"
            ]
            [ Html.div
                [ Attr.class "font-clickerscript text-3xl pt-2"
                , Attr.class "flex-auto self-end lg:col-start-2 lg:pl-2"
                ]
                [ Html.text "Little Bo Peep" ]
            , Html.button [] [ Html.text "Menu" ]
            ]
        ]
