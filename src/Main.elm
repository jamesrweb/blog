module Main exposing (main)

import API.API exposing (ApiResponse, apiResponseDecoder)
import API.Post exposing (ForemPosts, viewPosts)
import Browser
import Html exposing (Html)
import Html.Attributes
import Http



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


type Model
    = Failure
    | Loading
    | Success ForemPosts


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Message )
init _ =
    ( Loading, fetchPosts )



-- UPDATE


type Message
    = FetchedPosts (Result Http.Error ApiResponse)


update : Message -> Model -> ( Model, Cmd Message )
update msg _ =
    case msg of
        FetchedPosts result ->
            case result of
                Ok response ->
                    ( Success response.posts, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Message
view model =
    Html.main_
        [ Html.Attributes.class "container" ]
        [ Html.header []
            [ Html.h1 [ Html.Attributes.class "display-2 mt-3 mb-4 mb-md-5 text-center" ] [ Html.text "Latest posts" ]
            ]
        , viewForModel model
        ]


viewForModel : Model -> Html Message
viewForModel model =
    case model of
        Failure ->
            Html.p []
                [ Html.text "I couldn't load posts right now, perhaps try refreshing your browser or come back again later?" ]

        Loading ->
            Html.p [] [ Html.text "Loading posts..." ]

        Success posts ->
            viewPosts posts



-- HTTP


fetchPosts : Cmd Message
fetchPosts =
    Http.get
        { url = "https://dev.to/api/articles?username=jamesrweb"
        , expect = Http.expectJson FetchedPosts apiResponseDecoder
        }
