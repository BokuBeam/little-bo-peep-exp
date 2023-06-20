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


sideArrowLeft : Html msg
sideArrowLeft =
    svg [ width "50", height "300" ]
        [ path
            [ class "fill-white/50"
            , d "m 46.112641,6.2386054 -1e-6,287.4440646 c 0,1.9084 -4.372139,1.9366 -4.871614,0.0947 L 3,152.75953 c -0.4994773,-1.84187 -0.4973483,-3.02917 0,-4.87162 L 41.241026,6.2226038 c 0.497348,-1.8424461 4.871615,-1.8923914 4.871615,0.016002 z"
            ]
            []
        ]
