module Icon exposing (..)

import Html exposing (Html)
import Svg exposing (circle, g, path, svg)
import Svg.Attributes exposing (class, cx, cy, d, height, r, viewBox, width)


arrowUp : Html msg
arrowUp =
    svg [ width "40", height "40" ]
        [ g []
            [ circle
                [ class "fill-none stroke-black stroke-1"
                , cx "20"
                , cy "20"
                , r "17"
                ]
                []
            , path
                [ class "fill-none stroke-black stroke-1"
                , d "M 9,20 30,20 M 22,12 30,20 22,28"
                ]
                []
            ]
        ]
