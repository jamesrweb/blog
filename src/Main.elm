module Main exposing (main)

import API.API exposing (ApiResponse, apiResponseDecoder)
import API.Post exposing (Posts, postDecoder, viewPosts)
import Browser
import Html.Styled as Styled
import Http exposing (Error(..))
import Json.Decode as Decode
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
    = Failure Http.Error
    | Loading
    | Success Posts


type alias Flags =
    String


init : Flags -> ( Model, Cmd Message )
init forem_api_key =
    ( Loading, fetchPosts forem_api_key )



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

                Err error ->
                    ( Failure error, Cmd.none )



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
        Failure error ->
            Styled.pre []
                [ Styled.text (httpErrorToString error) ]

        -- Styled.p []
        --     [ Styled.text "I couldn't load posts right now, perhaps try refreshing your browser or come back again later?" ]
        Loading ->
            Styled.p [] [ Styled.text "Loading posts..." ]

        Success posts ->
            viewPosts posts



-- HTTP


fetchPosts : Flags -> Cmd Message
fetchPosts forem_api_key =
    Http.request
        { method = "GET"
        , url = "https://dev.to/api/articles/me/published"
        , expect = Http.expectJson FetchedPosts apiResponseDecoder
        , headers =
            [ Http.header "api-key" forem_api_key ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        BadUrl url ->
            "The URL " ++ url ++ " was invalid."

        Timeout ->
            "The server did not receive a complete request message within the time that it was prepared to wait."

        NetworkError ->
            "The server was unreachable, please check your network connection."

        BadStatus 500 ->
            "The server has encountered a situation it doesn't know how to handle."

        BadStatus 400 ->
            "The server could not understand the request due to invalid syntax."

        BadStatus status ->
            "Unknown error code returned: " ++ String.fromInt status

        BadBody errorMessage ->
            errorMessage
