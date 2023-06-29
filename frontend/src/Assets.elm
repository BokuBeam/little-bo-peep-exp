module Assets exposing (..)


root : String
root =
    "/assets"


image : String -> String
image imageName =
    root ++ "/images/" ++ imageName


article : String -> String
article articleName =
    root ++ "/articles/" ++ articleName ++ ".emu"
