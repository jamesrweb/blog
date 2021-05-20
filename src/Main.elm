module Main exposing (main)

import Browser
import Date
import Html.Styled as Styled
import Html.Styled.Attributes as Attributes
import Http
import Iso8601
import Json.Decode as Decode
import Styles
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
    let
        externalStylesheets =
            Styles.global :: Styles.reset
    in
    Styled.main_
        [ Styles.container ]
        (externalStylesheets ++ [ viewHeader, viewForModel model ])


viewForModel : Model -> Styled.Html Message
viewForModel model =
    case model of
        Failure ->
            Styled.p []
                [ Styled.text "I couldn't load posts right now, perhaps try refreshing your browser or come back again later?" ]

        Loading ->
            Styled.p [] [ Styled.text "Loading posts..." ]

        Success posts ->
            viewPosts posts


viewHeader : Styled.Html Message
viewHeader =
    Styled.header [ Styles.header ] [ Styled.h1 [] [ Styled.text "Latest posts" ] ]


viewPostLink : Post -> Styled.Html Message
viewPostLink post =
    Styled.a
        [ Styles.link
        , Attributes.href post.link
        , Attributes.rel "noopener noreferrer"
        , Attributes.target "_blank"
        ]
        [ viewPostTitle post.title, viewTime post.published ]


viewPostTitle : String -> Styled.Html Message
viewPostTitle title =
    Styled.h2 [ Styles.postTitle ] [ Styled.text title ]


viewTime : String -> Styled.Html Message
viewTime timestamp =
    Styled.time
        [ Styles.time
        , Attributes.datetime timestamp
        ]
        [ Styled.text ("Published on the " ++ formatDate timestamp) ]


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
    Styled.li [ Styles.post ] [ viewPostLink post ]


viewPosts : List Post -> Styled.Html Message
viewPosts posts =
    case posts of
        [] ->
            Styled.text "No posts are currently available"

        _ ->
            Styled.ul [ Styles.postList ] (List.map viewPost posts)



-- HTTP


fetchPosts : Flags -> Cmd Message
fetchPosts supabase_api_key =
    Http.request
        { method = "GET"
        , url = "https://rhdtxwxbqieflugetslw.supabase.co/rest/v1/posts?select=*"
        , expect = Http.expectJson FetchedPosts (Decode.list postsDecoder)
        , headers =
            [ Http.header "apikey" supabase_api_key
            , Http.header "Authorization" ("Bearer " ++ supabase_api_key)
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
