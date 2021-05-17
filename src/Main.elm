module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (href, rel, target)
import Http
import Json.Decode exposing (Decoder, field, string)



-- MAIN


main : Program Flags Model Message
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Post =
    { title : String
    , link : String
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


view : Model -> Html Message
view model =
    case model of
        Failure ->
            div []
                [ text "I couldn't load posts right now, perhaps try refreshing your browser or come back again later?" ]

        Loading ->
            text "Loading posts..."

        Success posts ->
            div []
                [ h2 [] [ text "Latest posts" ]
                , viewPosts posts
                ]


renderPost : Post -> Html Message
renderPost post =
    li []
        [ a [ href post.link, rel "noopener noreferrer", target "_blank" ] [ text post.title ]
        ]


viewPosts : List Post -> Html Message
viewPosts posts =
    case posts of
        [] ->
            text "No posts are currently available"

        _ ->
            ul [] (List.map renderPost posts)



-- HTTP


fetchPosts : Flags -> Cmd Message
fetchPosts supabase_api_key =
    Http.request
        { method = "GET"
        , url = "https://rhdtxwxbqieflugetslw.supabase.co/rest/v1/posts?select=*"
        , expect = Http.expectJson FetchedPosts (Json.Decode.list postsDecoder)
        , headers =
            [ Http.header "apikey" supabase_api_key
            , Http.header "Authorization" ((++) "Bearer" supabase_api_key)
            ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


postsDecoder : Decoder Post
postsDecoder =
    Json.Decode.map2 Post
        (field "title" string)
        (field "link" string)
