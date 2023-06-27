module Header exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Icon


view : Html msg
view =
    Html.div
        [ Attr.class "flex justify-center items-center"
        , Attr.class "fixed w-full bg-white z-50"
        , Attr.class "border-b-2 border-t-10"
        , Attr.class "h-14"
        ]
        [ Html.div
            [ Attr.class "flex justify-center content-center"
            , Attr.class "w-full md:w-192 lg:w-full lg:grid lg:grid-cols-[2fr_3fr_2fr] pl-4"
            , Attr.id "Header"
            ]
            [ Html.div
                [ Attr.class "font-clickerscript text-3xl"
                , Attr.class "flex-auto self-end lg:col-start-2 lg:pl-2"
                ]
                [ Html.text "Little Bo Peep" ]
            ]
        ]
