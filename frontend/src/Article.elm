module Article exposing (view)

import Browser exposing (document)
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode
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
                    Html.div
                        [ Attr.id "Article"
                        , Attr.class "w-full"
                        , Attr.class "flex justify-center align-center"
                        ]
                        [ Html.div
                            [ Attr.class "w-full sm:w-128"
                            ]
                            html.body
                        ]

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
                    , Attr.class "flex flex-col"
                    ]
                    (Html.h1 [ Attr.class "text-4xl py-8 px-4" ] meta.title
                        :: body
                    )
                ]
            }
        )
        { metadata = metadata
        , body =
            Mark.manyOf
                [ math
                , thoughtMath
                , Mark.map (Html.p [ Attr.class "indent-1 text-xl px-4" ]) text
                ]
        }



{- Handle Text -}


text : Mark.Block (List (Html msg))
text =
    Mark.textWith
        { view = viewText
        , replacements = Mark.commonReplacements
        , inlines =
            [ Mark.verbatim "math" <|
                \str -> Html.span [] [ mathText InlineMathMode str ]
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
            [ Html.text string
            ]

    else
        Html.span [] [ Html.text string ]


metadata : Mark.Block { title : List (Html msg) }
metadata =
    Mark.record "Article"
        (\title ->
            { title = title
            }
        )
        |> Mark.field "title" text
        |> Mark.toBlock


thoughtMath : Mark.Block (Html msg)
thoughtMath =
    Mark.record "ThoughtMath"
        (\img body position offset childOffset ->
            Html.div
                [ Attr.style "transform" ("translate" ++ offset)
                ]
                [ Html.img
                    [ Attr.src img
                    ]
                    []
                , Html.span
                    [ Attr.class "text-xl"
                    , Attr.style "transform" ("translate" ++ childOffset)
                    ]
                    [ mathText InlineMathMode body
                    ]
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
            Html.div
                [ Attr.class "px-4 text-xl" ]
                [ mathText DisplayMathMode str ]
        )
        Mark.string


type DisplayMode
    = InlineMathMode
    | DisplayMathMode


mathText : DisplayMode -> String -> Html msg
mathText displayMode content =
    let
        inline =
            InlineMathMode == displayMode
    in
    Html.node "math-text"
        [ Attr.classList [ ( "inline-block", inline ) ]
        , Attr.property "display" (Json.Encode.bool <| not inline)
        , Attr.property "content" (Json.Encode.string (content |> String.replace "\\ \\" "\\\\"))
        ]
        []
