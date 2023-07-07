module Article exposing (ArticleState(..), view)

import Assets
import Browser exposing (document)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Icon
import Json.Encode
import Mark exposing (Outcome(..))
import Mark.Error
import Styles


type alias ArticleData msg =
    { article : String
    , articleState : ArticleState
    , hideThoughtMsg : msg
    , showThoughtMsg : msg
    }


type ArticleState
    = ShowArticle
    | ShowSideRight


type alias DocumentData msg =
    { metadata :
        { title : List (Html msg)
        }
    , body : List (Html msg)
    }


document : ArticleData msg -> Mark.Document (DocumentData msg)
document data =
    Mark.documentWith
        (\meta body ->
            { metadata = meta
            , body =
                [ Html.div
                    [ Attr.class "font-baskerville w-full"
                    ]
                    (Html.div [ Attr.class Styles.largeGrid ]
                        [ Html.h1 [ Attr.class "lg:col-start-2 text-4xl p-4" ] meta.title ]
                        :: body
                    )
                ]
            }
        )
        { metadata = metadata
        , body =
            Mark.manyOf
                [ paragraph data
                , paragraphFlat data
                ]
        }


view : ArticleData msg -> Html msg
view data =
    case Mark.compile (document data) data.article of
        Mark.Success html ->
            Html.div
                [ Attr.id "Article"
                , Attr.class "w-full"
                , Attr.class "absolute flex justify-center align-center"
                ]
                [ Html.div
                    [ Attr.class "w-full md:w-192 lg:w-full transition duration-300"
                    , Attr.class "lg:overflow-visible"
                    , Attr.class "lg:translate-x-0"
                    , case data.articleState of
                        ShowArticle ->
                            Attr.class "overflow-hidden"

                        ShowSideRight ->
                            Attr.class "-translate-x-3/4 md:-translate-x-[85%]"
                    ]
                    html.body
                , sideBarButton data
                ]

        Mark.Almost { result, errors } ->
            -- This is the case where there has been an error,
            -- but it has been caught by `Mark.onError` and is still rendereable.
            Html.div []
                [ Html.div [] (viewErrors errors)
                , Html.div [] result.body
                , Html.text "Almost"
                ]

        Mark.Failure errors ->
            Html.div []
                [ Html.text "Article error:"
                , Html.div []
                    (viewErrors errors)
                ]


viewErrors : List Mark.Error.Error -> List (Html msg)
viewErrors errors =
    List.map
        (Mark.Error.toHtml Mark.Error.Light)
        errors


sideBarButton : ArticleData msg -> Html msg
sideBarButton data =
    Html.button
        [ Attr.class "z-40 bg-stone-300/50 hover:bg-stone-400/50"
        , Attr.class "transition duration-300"
        , Attr.class "lg:hidden fixed grid grid-cols-4 justify-end items-center"
        , Attr.class "w-full md:w-192 lg:w-full h-full lg:translate-0"
        , Attr.style "-webkit-tap-highlight-color" "transparent"
        , case data.articleState of
            ShowArticle ->
                Attr.class "opacity-0 pointer-events-none"

            ShowSideRight ->
                Attr.class "opacity-100 -translate-x-3/4 md:-translate-x-[85%]"
        , onClick data.hideThoughtMsg
        ]
        [ Html.div
            [ Attr.class "col-start-1 flex items-center justify-center" ]
            [ Icon.sideArrowLeft ]
        , Html.div
            [ Attr.class "col-start-4 flex items-center justify-center" ]
            [ Icon.sideArrowLeft ]
        ]


paragraph : ArticleData msg -> Mark.Block (Html msg)
paragraph data =
    Mark.block "Paragraph"
        (Html.p
            [ Attr.class "relative text-xl sm:leading-relaxed"
            , Attr.class "-translate-x-[1000px] lg:translate-x-0"
            , Attr.class Styles.smallGrid
            , Attr.class Styles.largeGrid
            ]
        )
        (Mark.manyOf
            [ math
            , imageRight data
            , Mark.map (Html.span [ Attr.class "first:indent-10 col-start-2 px-4" ]) text
            ]
        )


paragraphFlat : ArticleData msg -> Mark.Block (Html msg)
paragraphFlat data =
    Mark.block "ParagraphFlat"
        (Html.p
            [ Attr.class "relative indent-0 text-xl sm:leading-relaxed"
            , Attr.class "-translate-x-[1000px] lg:translate-x-0"
            , Attr.class Styles.smallGrid
            , Attr.class Styles.largeGrid
            ]
        )
        (Mark.manyOf
            [ math
            , imageRight data
            , Mark.map (Html.span [ Attr.class "col-start-2 px-4" ]) text
            ]
        )


text : Mark.Block (List (Html msg))
text =
    Mark.textWith
        { view = viewText
        , replacements = Mark.commonReplacements
        , inlines =
            [ Mark.verbatim "math" <|
                \str -> mathText InlineMathMode str
            ]
        }


viewText : { a | bold : Bool, italic : Bool } -> String -> Html msg
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


metadata : Mark.Block { title : List (Html msg) }
metadata =
    Mark.record "Article"
        (\title ->
            { title = title
            }
        )
        |> Mark.field "title" text
        |> Mark.toBlock


imageRight : ArticleData msg -> Mark.Block (Html msg)
imageRight data =
    Mark.record "ImageRight" (viewImageRight data)
        |> Mark.field "img" Mark.string
        |> Mark.field "offsetX" Mark.string
        |> Mark.field "offsetY" Mark.string
        |> Mark.toBlock


viewImageRight : ArticleData msg -> String -> String -> String -> Html msg
viewImageRight data img offsetX offsetY =
    let
        image =
            Html.button
                [ case data.articleState of
                    ShowSideRight ->
                        onClick data.hideThoughtMsg

                    ShowArticle ->
                        onClick data.showThoughtMsg
                , Attr.class "flex shrink-0"
                , Attr.class "transition-opacity duration-300"
                , Attr.class "lg:transition-none lg:opacity-100"
                , Attr.style "transform"
                    (String.concat
                        [ "translate("
                        , offsetX
                        , ", "
                        , offsetY
                        , ")"
                        ]
                    )
                ]
                [ Html.img [ Attr.src <| Assets.image img ] []
                ]
    in
    Html.div
        [ Attr.class "col-start-3 h-0 flex items-center justify-start"
        ]
        [ image
        ]


math : Mark.Block (Html msg)
math =
    Mark.block "Math"
        (\str ->
            Html.div
                [ Attr.class "indent-0 text-xl min-h-[4rem] flex items-center justify-center col-start-2" ]
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
        , Attr.class "indent-0"
        , Attr.property "display" (Json.Encode.bool <| not inline)
        , Attr.property "content" (Json.Encode.string (content |> String.replace "\\ \\" "\\\\"))
        ]
        []
