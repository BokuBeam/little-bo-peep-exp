module Assets exposing (..)


root : String
root =
    "/assets"


image : String -> String
image src =
    root ++ "/images/" ++ src
