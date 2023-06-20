module Article exposing (view)

import Browser exposing (document)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Icon
import Json.Encode
import Mark exposing (Outcome(..))
import Mark.Error
import Msg exposing (Msg(..))


type alias ArticleData =
    { article : String
    , thoughtShowing : Bool
    }


view : ArticleData -> Html Msg
view data =
    case Mark.compile (document data.thoughtShowing) data.article of
        Mark.Success html ->
            Html.div
                [ Attr.id "Article"
                , Attr.class "w-full overflow-hidden"
                , Attr.class "flex justify-center align-center"
                ]
                [ Html.div
                    [ Attr.class "w-full md:w-192 lg:w-128 transition"
                    , Attr.classList
                        [ ( "-translate-x-2/3", data.thoughtShowing )
                        , ( "bg-slate-100", data.thoughtShowing )
                        ]
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


viewErrors : List Mark.Error.Error -> List (Html Msg)
viewErrors errors =
    List.map
        (Mark.Error.toHtml Mark.Error.Light)
        errors


document :
    Bool
    ->
        Mark.Document
            { metadata :
                { title : List (Html Msg) }
            , body : List (Html Msg)
            }
document thoughtShowing =
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
                [ paragraph thoughtShowing
                , paragraphFlat thoughtShowing
                ]
        }


paragraph : Bool -> Mark.Block (Html Msg)
paragraph thoughtShowing =
    Mark.block "Paragraph"
        (Html.p [ Attr.class "relative indent-10 text-xl px-4 sm:leading-relaxed" ])
        (Mark.manyOf
            [ math
            , thoughtMath thoughtShowing
            , Mark.map (Html.span []) text
            ]
        )


paragraphFlat : Bool -> Mark.Block (Html Msg)
paragraphFlat thoughtShowing =
    Mark.block "ParagraphFlat"
        (Html.p [ Attr.class "relative indent-0 text-xl px-4 sm:leading-relaxed" ])
        (Mark.manyOf
            [ math
            , thoughtMath thoughtShowing
            , Mark.map (Html.span []) text
            ]
        )



{- Handle Text -}


text : Mark.Block (List (Html Msg))
text =
    Mark.textWith
        { view = viewText
        , replacements = Mark.commonReplacements
        , inlines =
            [ Mark.verbatim "math" <|
                \str -> mathText InlineMathMode str
            ]
        }


viewText :
    { a
        | bold : Bool
        , italic : Bool
    }
    -> String
    -> Html Msg
viewText styles string =
    if styles.bold || styles.italic then
        Html.span
            [ Attr.classList
                [ ( "font-baskerville-bold", styles.bold )
                , ( "font-baskerville-italic", styles.italic )
                ]
            , Attr.class "indent-0"
            ]
            [ Html.text string
            ]

    else
        Html.text string


metadata : Mark.Block { title : List (Html Msg) }
metadata =
    Mark.record "Article"
        (\title ->
            { title = title
            }
        )
        |> Mark.field "title" text
        |> Mark.toBlock


thoughtMath : Bool -> Mark.Block (Html Msg)
thoughtMath thoughtShowing =
    Mark.record "ThoughtMath"
        (\img body offset childOffset ->
            Html.div [ Attr.class "relative top-[-1rem]" ]
                [ Html.button
                    [ Attr.class "lg:hidden absolute bottom-0 right-0"
                    , Attr.classList [ ( "hidden", thoughtShowing ) ]
                    , onClick ShowThought
                    ]
                    [ Icon.arrowUp ]
                , Html.div
                    [ Attr.class "opacity-0 lg:opacity-100 block absolute bottom-0 right-[-50%] pointer-events-none"
                    , Attr.style "transform" ("translate" ++ offset)
                    ]
                    [ Html.span
                        [ Attr.class "text-xl absolute"
                        , Attr.style "transform" ("translate" ++ childOffset)
                        ]
                        [ mathText InlineMathMode body ]
                    , Html.img [ Attr.src img ] []
                    ]
                , Html.div
                    [ Attr.classList [ ( "hidden", not thoughtShowing ) ]
                    , Attr.class "block absolute bottom-0 right-[-50%] pointer-events-none"
                    , Attr.style "transform" ("translate" ++ offset)
                    ]
                    [ Html.span
                        [ Attr.class "text-xl absolute"
                        , Attr.style "transform" ("translate" ++ childOffset)
                        ]
                        [ mathText InlineMathMode body ]
                    , Html.img [ Attr.src img ] []
                    ]
                ]
        )
        |> Mark.field "img" Mark.string
        |> Mark.field "body" Mark.string
        |> Mark.field "offset" Mark.string
        |> Mark.field "childOffset" Mark.string
        |> Mark.toBlock


math : Mark.Block (Html Msg)
math =
    Mark.block "Math"
        (\str ->
            Html.div
                [ Attr.class "indent-0 text-xl min-h-[4rem] flex items-center justify-center" ]
                [ mathText DisplayMathMode str ]
        )
        Mark.string


type DisplayMode
    = InlineMathMode
    | DisplayMathMode


mathText : DisplayMode -> String -> Html Msg
mathText displayMode content =
    let
        inline =
            InlineMathMode == displayMode
    in
    Html.node "math-text"
        [ Attr.classList [ ( "inline-block", inline ) ]
        , Attr.class "indent-0"
        , Attr.property "display" (Json.Encode.bool <| not inline)
        , Attr.property "content" (Json.Encode.string (content |> String.replace "\\ \\" "\\\\"))
        ]
        []
