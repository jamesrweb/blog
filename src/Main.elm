module Main exposing (main)

import Browser
import Html as H
import Html.Attributes as A
import Http
import Json.Decode as D



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


view : Model -> H.Html Message
view model =
    case model of
        Failure ->
            H.div []
                [ H.text "I couldn't load posts right now, perhaps try refreshing your browser or come back again later?" ]

        Loading ->
            H.text "Loading posts..."

        Success posts ->
            H.div []
                [ H.h2 [] [ H.text "Latest posts" ]
                , viewPosts posts
                ]


renderLink : String -> String -> H.Html Message
renderLink link content =
    H.a
        [ A.href link
        , A.rel "noopener noreferrer"
        , A.target "_blank"
        ]
        [ H.text content ]


renderPost : Post -> H.Html Message
renderPost post =
    H.li [] [ renderLink post.link post.title ]


viewPosts : List Post -> H.Html Message
viewPosts posts =
    case posts of
        [] ->
            H.text "No posts are currently available"

        _ ->
            H.ul [] (List.map renderPost posts)



-- HTTP


fetchPosts : Flags -> Cmd Message
fetchPosts supabase_api_key =
    Http.request
        { method = "GET"
        , url = "https://rhdtxwxbqieflugetslw.supabase.co/rest/v1/posts?select=*"
        , expect = Http.expectJson FetchedPosts (D.list postsDecoder)
        , headers =
            [ Http.header "apikey" supabase_api_key
            , Http.header "Authorization" ((++) "Bearer" supabase_api_key)
            ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


postsDecoder : D.Decoder Post
postsDecoder =
    D.map2 Post
        (D.field "title" D.string)
        (D.field "link" D.string)
