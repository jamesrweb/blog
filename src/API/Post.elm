module API.Post exposing (ForemPost, ForemPosts, postsDecoder, viewPosts)

import Date
import Html exposing (Html)
import Html.Attributes
import Iso8601
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Time



-- Model


type alias ForemPost =
    { canonicalUrl : String
    , collectionId : Maybe Int
    , commentsCount : Int
    , coverImage : Maybe String
    , createdAt : String
    , crosspostedAt : Maybe String
    , description : String
    , editedAt : Maybe String
    , id : Int
    , lastCommentAt : Maybe String
    , path : String
    , positiveReactionsCount : Int
    , publicReactionsCount : Int
    , publishedAt : String
    , publishedTimestamp : String
    , readablePublishDate : String
    , readingTimeMinutes : Int
    , slug : String
    , socialImage : String
    , tagList : List String
    , tags : String
    , title : String
    , typeOf : String
    , url : String
    , user : ForemUser
    }


type alias ForemPosts =
    List ForemPost


type alias ForemUser =
    { githubUsername : String
    , name : String
    , profileImage : String
    , profileImage90 : String
    , twitterUsername : Maybe String
    , username : String
    , websiteUrl : String
    }



-- View


viewPosts : List ForemPost -> Html msg
viewPosts posts =
    case posts of
        [] ->
            Html.text "No posts are currently available"

        _ ->
            Html.ul [ Html.Attributes.class "list-unstyled row g-2" ] (List.map viewPost posts)


viewPost : ForemPost -> Html msg
viewPost post =
    Html.li [ Html.Attributes.class "col-12" ] [ viewPostCard post ]


viewPostCard : ForemPost -> Html msg
viewPostCard post =
    Html.article [ Html.Attributes.class "card h-100" ]
        [ Html.div [ Html.Attributes.class "card-body d-flex flex-column justify-content-between gap-3" ]
            [ viewPostTitle post
            , viewPublishedDate post.publishedAt
            , viewPostPreview post
            ]
        ]


viewPostPreview : ForemPost -> Html msg
viewPostPreview post =
    Html.p []
        [ Html.text (post.description ++ " ")
        , viewPostReadMoreLink post
        , Html.text "."
        ]


viewPostReadMoreLink : ForemPost -> Html msg
viewPostReadMoreLink post =
    Html.a
        [ Html.Attributes.href post.url
        , Html.Attributes.rel "noopener noreferrer"
        , Html.Attributes.target "_blank"
        ]
        [ Html.text ("continue reading \"" ++ post.title ++ "\"") ]


viewPostTitle : ForemPost -> Html msg
viewPostTitle post =
    Html.h2 [ Html.Attributes.class "display-6 m-0" ] [ Html.text post.title ]


viewPublishedDate : String -> Html msg
viewPublishedDate timestamp =
    Html.time
        [ Html.Attributes.datetime timestamp
        ]
        [ Html.text ("Published on the " ++ formatDate timestamp) ]


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


parseISO8601 : String -> Maybe Time.Posix
parseISO8601 timestamp =
    case Iso8601.toTime timestamp of
        Ok posix ->
            Just posix

        Err _ ->
            Nothing



-- HTTP


postDecoder : Decode.Decoder ForemPost
postDecoder =
    Decode.succeed ForemPost
        |> Pipeline.required "canonical_url" Decode.string
        |> Pipeline.required "collection_id" (Decode.maybe Decode.int)
        |> Pipeline.required "comments_count" Decode.int
        |> Pipeline.required "cover_image" (Decode.maybe Decode.string)
        |> Pipeline.required "created_at" Decode.string
        |> Pipeline.required "crossposted_at" (Decode.maybe Decode.string)
        |> Pipeline.required "description" Decode.string
        |> Pipeline.required "edited_at" (Decode.maybe Decode.string)
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "last_comment_at" (Decode.maybe Decode.string)
        |> Pipeline.required "path" Decode.string
        |> Pipeline.required "positive_reactions_count" Decode.int
        |> Pipeline.required "public_reactions_count" Decode.int
        |> Pipeline.required "published_at" Decode.string
        |> Pipeline.required "published_timestamp" Decode.string
        |> Pipeline.required "readable_publish_date" Decode.string
        |> Pipeline.required "reading_time_minutes" Decode.int
        |> Pipeline.required "slug" Decode.string
        |> Pipeline.required "social_image" Decode.string
        |> Pipeline.required "tag_list" (Decode.list Decode.string)
        |> Pipeline.required "tags" Decode.string
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "type_of" Decode.string
        |> Pipeline.required "url" Decode.string
        |> Pipeline.required "user" foremUserDecoder


postsDecoder : Decode.Decoder ForemPosts
postsDecoder =
    Decode.list postDecoder


foremUserDecoder : Decode.Decoder ForemUser
foremUserDecoder =
    Decode.succeed ForemUser
        |> Pipeline.required "github_username" Decode.string
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "profile_image" Decode.string
        |> Pipeline.required "profile_image_90" Decode.string
        |> Pipeline.required "twitter_username" (Decode.maybe Decode.string)
        |> Pipeline.required "username" Decode.string
        |> Pipeline.required "website_url" Decode.string
