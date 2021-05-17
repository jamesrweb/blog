module Main exposing (main)

import Browser
import Html
import Http
import Html.Attributes as Attributes
import Json.Decode as Decode



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


view : Model -> Html.Html Message
view model =
    case model of
        Failure ->
            Html.div []
                [ Html.text "I couldn't load posts right now, perhaps try refreshing your browser or come back again later?" ]

        Loading ->
            Html.text "Loading posts..."

        Success posts ->
            Html.div []
                [ Html.h2 [] [ Html.text "Latest posts" ]
                , viewPosts posts
                ]


renderLink : String -> String -> Html.Html Message
renderLink link content =
    Html.a
        [ Attributes.href link
        , Attributes.rel "noopener noreferrer"
        , Attributes.target "_blank"
        ]
        [ Html.text content ]


renderPost : Post -> Html.Html Message
renderPost post =
    Html.li [] [ renderLink post.link post.title ]


viewPosts : List Post -> Html.Html Message
viewPosts posts =
    case posts of
        [] ->
            Html.text "No posts are currently available"

        _ ->
            Html.ul [] (List.map renderPost posts)



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
    Decode.map2 Post
        (Decode.field "title" Decode.string)
        (Decode.field "link" Decode.string)
