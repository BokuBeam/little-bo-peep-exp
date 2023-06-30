module Nav exposing (..)

import Articles exposing (Articles)


type alias Nav =
    List
        { title : String
        , url : String
        }


fromArticles : Articles -> Nav
fromArticles articles =
    Articles.toList articles
        |> List.map
            (\( url, article ) ->
                { title = url
                , url = url
                }
            )
