module Main exposing (main)

import API.API exposing (ApiResponse, apiResponseDecoder)
import API.Post exposing (ForemPosts, viewPosts)
import Browser
import Html.Styled as Styled
import Http
import Styles



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


view : Model -> Styled.Html Message
view model =
    Styled.main_
        [ Styles.container ]
        ((Styles.global :: Styles.reset)
            ++ [ Styled.header [ Styles.header ]
                    [ Styled.h1 [] [ Styled.text "Latest posts" ]
                    ]
               , viewForModel model
               ]
        )


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



-- HTTP


fetchPosts : Cmd Message
fetchPosts =
    Http.get
        { url = "https://dev.to/api/articles?username=jamesrweb"
        , expect = Http.expectJson FetchedPosts apiResponseDecoder
        }
