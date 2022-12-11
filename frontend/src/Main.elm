module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Icon
import Mark
import Mark.Error


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


type alias Model =
    { source : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { source = Nothing }
    , Http.get
        { url = "/articles/ch_1.emu"
        , expect = Http.expectString GotArticle
        }
    )



-- UPDATE


type Msg
    = GotArticle (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticle result ->
            case result of
                Ok src ->
                    ( { model | source = Just src }
                    , Cmd.none
                    )

                Err err ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Little Bo Peep"
    , body =
        [ Html.div
            [ Attr.class "w-full"
            ]
            [ header
            , article model.source
            ]
        ]
    }


header : Html Msg
header =
    Html.div
        [ Attr.class "w-full flex justify-center"
        , Attr.class "border-b-2 border-t-10"
        , Attr.class "py-4"
        ]
        [ Html.div
            [ Attr.class "flex justify-center content-center"
            , Attr.class "w-128"
            ]
            [ Html.div
                [ Attr.class "font-clickerscript text-3xl"
                , Attr.class "flex-auto"
                ]
                [ Html.text "Little Bo Peep" ]
            , Html.div
                []
                [ Icon.arrowUp ]
            ]
        ]


article : Maybe String -> Html msg
article maybeSource =
    case maybeSource of
        Nothing ->
            Html.text "Loading"

        Just source ->
            case Mark.compile document source of
                Mark.Success html ->
                    Html.div [] html.body

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
                [ Html.div [ Attr.class "flex justify-center font-baskerville" ]
                    [ Html.div [ Attr.class "w-128" ]
                        (Html.h1 [ Attr.class "text-4xl py-8" ] meta.title
                            :: body
                        )
                    ]
                ]
            }
        )
        -- We have some required metadata that starts our document.
        { metadata = metadata
        , body =
            Mark.manyOf
                [ math
                , thought
                , Mark.map (Html.p [ Attr.class "text-xl" ]) text
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
                            String.concat
                                [ "$"
                                , str
                                , "$"
                                ]
                    in
                    Html.span [] [ Html.text padded ]
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
    Html.span
        [ Attr.classList
            [ ( "font-baskerville-bold", styles.bold )
            , ( "font-baskerville-italic", styles.italic )
            ]
        ]
        [ Html.text string ]


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
        (\img body ->
            Html.div [ Attr.class "relative h-0" ]
                [ Html.img [ Attr.src img, Attr.class "absolute inset-full" ] []
                , Html.span [ Attr.class "w-full absolute inset-full" ] [ Html.text body ]
                ]
        )
        |> Mark.field "img" Mark.string
        |> Mark.field "body" Mark.string
        |> Mark.toBlock


math : Mark.Block (Html msg)
math =
    Mark.block "Math"
        (\str ->
            let
                padded =
                    String.concat [ "$$", "\n", str, "\n", "$$" ]
            in
            Html.div
                [ Attr.class "py-6 text-l" ]
                [ Html.text padded ]
        )
        Mark.string
