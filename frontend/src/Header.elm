module Header exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Icon


view : Html msg
view =
    Html.div
        [ Attr.class "grid gap-0 items-center grid-cols-3"
        , Attr.class "w-3/1 md:w-384"
        , Attr.class "border-b-2 border-t-10"
        , Attr.class "py-4"
        ]
        [ Html.div
            [ Attr.class "flex justify-center content-center"
            , Attr.class "col-start-2 pl-4"
            , Attr.id "Header"
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
