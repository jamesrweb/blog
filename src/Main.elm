module Main exposing (main)

import Browser
import Css
import Css.Global
import Css.Reset as Reset
import Date
import Html.Styled as Styled
import Html.Styled.Attributes as Attributes
import Http
import Iso8601
import Json.Decode as Decode
import Time



-- MAIN


main : Program Flags Model Message
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view >> Styled.toUnstyled
        }



-- MODEL


type alias Post =
    { title : String
    , link : String
    , published : String
    }


type Model
    = Failure
    | Loading
    | Success (List Post)


type alias Flags =
    String


init : Flags -> ( Model, Cmd Message )
init supabase_api_key =
    ( Loading, fetchPosts supabase_api_key )



-- UPDATE


type Message
    = FetchedPosts (Result Http.Error (List Post))


update : Message -> Model -> ( Model, Cmd Message )
update msg _ =
    case msg of
        FetchedPosts result ->
            case result of
                Ok posts ->
                    ( Success posts, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Styled.Html Message
view model =
    Styled.div
        [ Attributes.css
            [ Css.padding (Css.rem 2)
            , Css.fontFamily Css.sansSerif
            , Css.fontSize (Css.rem 1.25)
            , Css.maxWidth (Css.rem 45)
            , Css.margin2 (Css.rem 0) Css.auto
            ]
        ]
        [ Reset.meyerV2
        , Reset.borderBoxV201408
        , Css.Global.global
            [ Css.Global.selector "html" [ Css.fontSize (Css.px 16) ]
            ]
        , viewHeader
        , viewForModel model
        ]


viewForModel : Model -> Styled.Html Message
viewForModel model =
    case model of
        Failure ->
            Styled.p []
                [ Styled.text "I couldn't load posts right now, perhaps try refreshing your browser or come back again later?" ]

        Loading ->
            Styled.p [] [ Styled.text "Loading posts..." ]

        Success posts ->
            Styled.main_ [] [ viewPosts posts ]


viewHeader : Styled.Html Message
viewHeader =
    Styled.header
        [ Attributes.css
            [ Css.padding2 (Css.rem 3) (Css.rem 0)
            , Css.textAlign Css.center
            , Css.fontSize (Css.rem 3)
            ]
        ]
        [ Styled.h1 [] [ Styled.text "Latest posts" ] ]


viewLink : Post -> Styled.Html Message
viewLink post =
    Styled.a
        [ Attributes.href post.link
        , Attributes.rel "noopener noreferrer"
        , Attributes.target "_blank"
        , Attributes.css
            [ Css.color Css.currentColor
            , Css.textDecoration Css.none
            , Css.display Css.inlineBlock
            ]
        ]
        [ viewPostTitle post.title
        , viewTime post.published
        ]


viewPostTitle : String -> Styled.Html Message
viewPostTitle title =
    Styled.h2
        [ Attributes.css
            [ Css.fontSize (Css.rem 1.5)
            , Css.marginBottom (Css.rem 0.5)
            ]
        ]
        [ Styled.text title ]


viewTime : String -> Styled.Html Message
viewTime timestamp =
    Styled.time
        [ Attributes.css
            [ Css.fontSize (Css.rem 1)
            ]
        , Attributes.datetime timestamp
        ]
        [ Styled.text (String.join " " [ "Published on the", formatDate timestamp ]) ]


parseISO8601 : String -> Maybe Time.Posix
parseISO8601 timestamp =
    case Iso8601.toTime timestamp of
        Ok posix ->
            Just posix

        Err _ ->
            Nothing


formatDate : String -> String
formatDate timestamp =
    let
        date =
            parseISO8601 timestamp
                |> Maybe.withDefault (Time.millisToPosix 0)
                |> Date.fromPosix Time.utc

        day =
            String.fromInt (Date.weekdayNumber date)

        month =
            String.fromInt (Date.monthNumber date)

        year =
            String.fromInt (Date.year date)
    in
    String.join "/" [ day, month, year ]


viewPost : Post -> Styled.Html Message
viewPost post =
    Styled.li
        [ Attributes.css
            [ Css.padding2 (Css.rem 2) (Css.rem 2)
            , Css.borderRadius (Css.rem 0.25)
            , Css.boxShadow5 (Css.rem 0) (Css.rem 0.25) (Css.rem 0.5) (Css.rem 0) (Css.rgba 0 0 0 0.2)
            , Css.marginBottom (Css.rem 1.5)
            ]
        ]
        [ viewLink post ]


viewPosts : List Post -> Styled.Html Message
viewPosts posts =
    case posts of
        [] ->
            Styled.text "No posts are currently available"

        _ ->
            Styled.ul
                [ Attributes.css
                    [ Css.listStyle Css.none
                    , Css.padding (Css.rem 0)
                    ]
                ]
                (List.map viewPost posts)



-- HTTP


fetchPosts : Flags -> Cmd Message
fetchPosts supabase_api_key =
    Http.request
        { method = "GET"
        , url = "https://rhdtxwxbqieflugetslw.supabase.co/rest/v1/posts?select=*"
        , expect = Http.expectJson FetchedPosts (Decode.list postsDecoder)
        , headers =
            [ Http.header "apikey" supabase_api_key
            , Http.header "Authorization" ((++) "Bearer" supabase_api_key)
            ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


postsDecoder : Decode.Decoder Post
postsDecoder =
    Decode.map3 Post
        (Decode.field "title" Decode.string)
        (Decode.field "link" Decode.string)
        (Decode.field "published" Decode.string)
