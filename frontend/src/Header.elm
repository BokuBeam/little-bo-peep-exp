module Header exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Icon


view : Html msg
view =
    Html.div
        [ Attr.class "w-full flex justify-center"
        , Attr.class "border-b-2 border-t-10"
        , Attr.class "py-4"
        ]
        [ Html.div
            [ Attr.class "flex justify-center content-center"
            , Attr.class "w-128"
            ]
            [ Html.div
                [ Attr.class "font-clickerscript text-3xl"
                , Attr.class "flex-auto"
                ]
                [ Html.text "Little Bo Peep" ]
            , Html.div
                []
                [ Icon.arrowUp ]
            ]
        ]
