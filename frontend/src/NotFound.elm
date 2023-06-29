module NotFound exposing (..)

import Html exposing (Html)


view : String -> Html msg
view error =
    Html.div [] [ Html.text error ]
