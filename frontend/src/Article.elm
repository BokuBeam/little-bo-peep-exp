module Article exposing (view)

import Assets
import Browser exposing (document)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Icon
import Json.Encode
import Mark exposing (Outcome(..))
import Mark.Error
import Msg exposing (Msg(..))
import Styles


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
                , Attr.class "w-full"
                , Attr.class "absolute flex justify-center align-center"
                ]
                [ Html.div
                    [ Attr.class "w-full md:w-192 lg:w-full transition duration-300"
                    , Attr.class "lg:overflow-visible"
                    , Attr.class "lg:translate-x-0"
                    , Attr.classList
                        [ ( "-translate-x-3/4 md:-translate-x-[85%]", data.thoughtShowing )
                        , ( "overflow-hidden", not data.thoughtShowing )
                        ]
                    ]
                    html.body
                , sideBarButton data.thoughtShowing
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


sideBarButton : Bool -> Html Msg
sideBarButton thoughtShowing =
    Html.button
        [ Attr.class "z-40 bg-stone-300/50 hover:bg-stone-400/50"
        , Attr.class "transition duration-300"
        , Attr.class "lg:hidden fixed grid grid-cols-4 justify-end items-center"
        , Attr.class "w-full md:w-192 lg:w-full h-full lg:translate-0"
        , Attr.style "-webkit-tap-highlight-color" "transparent"
        , Attr.classList
            [ ( "opacity-0 pointer-events-none", not thoughtShowing )
            , ( "opacity-100 -translate-x-3/4 md:-translate-x-[85%]", thoughtShowing )
            ]
        , onClick HideThought
        ]
        [ Html.div
            [ Attr.class "col-start-1 flex items-center justify-center" ]
            [ Icon.sideArrowLeft ]
        , Html.div
            [ Attr.class "col-start-4 flex items-center justify-center" ]
            [ Icon.sideArrowLeft ]
        ]


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
                    [ Attr.class "font-baskerville w-full"
                    ]
                    (Html.div [ Attr.class Styles.largeGrid ]
                        [ Html.h1 [ Attr.class "lg:col-start-2 mt-14 lg:mt-20 text-4xl p-4" ] meta.title ]
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
        (Html.p
            [ Attr.class "relative text-xl sm:leading-relaxed"
            , Attr.class "-translate-x-3/4 lg:translate-x-0"
            , Attr.class Styles.smallGrid
            , Attr.class Styles.largeGrid
            ]
        )
        (Mark.manyOf
            [ math
            , imageRight thoughtShowing
            , Mark.map (Html.span [ Attr.class "first:indent-10 col-start-2 px-4" ]) text
            ]
        )


paragraphFlat : Bool -> Mark.Block (Html Msg)
paragraphFlat thoughtShowing =
    Mark.block "ParagraphFlat"
        (Html.p
            [ Attr.class "relative indent-0 text-xl sm:leading-relaxed"
            , Attr.class "grid -translate-x-3/4 lg:translate-x-0"
            , Attr.class Styles.smallGrid
            , Attr.class Styles.largeGrid
            ]
        )
        (Mark.manyOf
            [ math
            , imageRight thoughtShowing
            , Mark.map (Html.span [ Attr.class "col-start-2 px-4" ]) text
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


imageRight : Bool -> Mark.Block (Html Msg)
imageRight thoughtShowing =
    Mark.record "ImageRight" (viewImageRight thoughtShowing)
        |> Mark.field "img" Mark.string
        |> Mark.field "offsetX" Mark.string
        |> Mark.field "offsetY" Mark.string
        |> Mark.toBlock


viewImageRight : Bool -> String -> String -> String -> Html Msg
viewImageRight thoughtShowing img offsetX offsetY =
    let
        imageButton =
            Html.button
                [ Attr.class "lg:hidden"
                , Attr.class "transition-opacity duration-300"
                , Attr.class "-ml-10 mt-16"
                , Attr.classList
                    [ ( "opacity-0", thoughtShowing )
                    , ( "opacity-100", not thoughtShowing )
                    ]
                , onClick ShowThought
                ]
                [ Icon.arrowUp ]

        image =
            Html.div
                [ Attr.classList
                    [ ( "opacity-0", not thoughtShowing )
                    , ( "opacity-100", thoughtShowing )
                    ]
                , Attr.class "flex shrink-0"
                , Attr.class "pointer-events-none"
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
        [ imageButton
        , image
        ]


math : Mark.Block (Html Msg)
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
