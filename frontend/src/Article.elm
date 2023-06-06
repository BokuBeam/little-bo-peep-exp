module Article exposing (view)

import Browser exposing (document)
import Html exposing (Html)
import Html.Attributes as Attr
import Mark exposing (Outcome(..))
import Mark.Error


view : Maybe String -> Html msg
view maybeSource =
    case maybeSource of
        Nothing ->
            Html.div [] []

        Just source ->
            case Mark.compile document source of
                Mark.Success html ->
                    Html.div [ Attr.class "w-full" ] html.body

                Mark.Almost { result, errors } ->
                    -- This is the case where there has been an error,
                    -- but it has been caught by `Mark.onError` and is still rendereable.
                    Html.div []
                        [ Html.div [] (viewErrors errors)
                        , Html.div [] result.body
                        ]

                Mark.Failure errors ->
                    Html.div []
                        (viewErrors errors)


viewErrors : List Mark.Error.Error -> List (Html msg)
viewErrors errors =
    List.map
        (Mark.Error.toHtml Mark.Error.Light)
        errors


document :
    Mark.Document
        { metadata :
            { title : List (Html msg) }
        , body : List (Html msg)
        }
document =
    Mark.documentWith
        (\meta body ->
            { metadata = meta
            , body =
                [ Html.div
                    [ Attr.class "font-baskerville"
                    , Attr.class "grid gap-0 items-center grid-cols-3"
                    , Attr.class "w-3/1 md:w-300"
                    ]
                    (Html.h1 [ Attr.class "text-4xl py-8 col-start-2 px-4" ] meta.title
                        :: body
                    )
                ]
            }
        )
        { metadata = metadata
        , body =
            Mark.manyOf
                [ math
                , thought
                , Mark.map (Html.p [ Attr.class "text-xl col-start-2 px-4" ]) text
                ]
        }



{- Handle Text -}


text : Mark.Block (List (Html msg))
text =
    Mark.textWith
        { view = viewText
        , replacements = Mark.commonReplacements
        , inlines =
            [ Mark.verbatim "math"
                (\str ->
                    let
                        padded =
                            String.concat [ "$", str, "$" ]
                    in
                    Html.text padded
                )
            ]
        }


viewText :
    { a
        | bold : Bool
        , italic : Bool
    }
    -> String
    -> Html msg
viewText styles string =
    if styles.bold || styles.italic then
        Html.span
            [ Attr.classList
                [ ( "font-baskerville-bold", styles.bold )
                , ( "font-baskerville-italic", styles.italic )
                ]
            ]
            [ Html.text string ]

    else
        Html.text string


metadata : Mark.Block { title : List (Html msg) }
metadata =
    Mark.record "Article"
        (\title ->
            { title = title
            }
        )
        |> Mark.field "title" text
        |> Mark.toBlock


thought : Mark.Block (Html msg)
thought =
    Mark.record "Thought"
        (\img body position offset childOffset ->
            Html.div
                [ Attr.class <|
                    if position == "left" then
                        "col-start-1"

                    else
                        "col-start-3"
                , Attr.class "grid items-center h-0"
                , Attr.style "transform" ("translate" ++ offset)
                ]
                [ Html.img
                    [ Attr.src img
                    , Attr.class "col-start-1 row-start-1"
                    ]
                    []
                , Html.span
                    [ Attr.class "text-xl col-start-1 row-start-1"
                    , Attr.style "transform" ("translate" ++ childOffset)
                    ]
                    [ Html.text body ]
                ]
        )
        |> Mark.field "img" Mark.string
        |> Mark.field "body" Mark.string
        |> Mark.field "position" Mark.string
        |> Mark.field "offset" Mark.string
        |> Mark.field "childOffset" Mark.string
        |> Mark.toBlock


math : Mark.Block (Html msg)
math =
    Mark.block "Math"
        (\str ->
            let
                padded =
                    String.concat [ "$$", str, "$$" ]
            in
            Html.div
                [ Attr.class "px-4 text-xl col-start-2" ]
                [ Html.text padded ]
        )
        Mark.string
