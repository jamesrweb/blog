module API.Post exposing (ForemPost, ForemPosts, postsDecoder, viewPosts)

import Date
import Html.Styled as Styled
import Html.Styled.Attributes as Attributes
import Iso8601
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Styles
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


viewPosts : List ForemPost -> Styled.Html msg
viewPosts posts =
    case posts of
        [] ->
            Styled.text "No posts are currently available"

        _ ->
            Styled.ul [ Styles.postList ] (List.map viewPost posts)


viewPost : ForemPost -> Styled.Html msg
viewPost post =
    Styled.li [ Styles.post ] [ viewPostLink post ]


viewPostLink : ForemPost -> Styled.Html msg
viewPostLink post =
    Styled.a
        [ Styles.link
        , Attributes.href post.url
        , Attributes.rel "noopener noreferrer"
        , Attributes.target "_blank"
        ]
        [ viewPostTitle post.title, viewTime post.publishedAt ]


viewPostTitle : String -> Styled.Html msg
viewPostTitle title =
    Styled.h2 [ Styles.postTitle ] [ Styled.text title ]


viewTime : String -> Styled.Html msg
viewTime timestamp =
    Styled.time
        [ Styles.time
        , Attributes.datetime timestamp
        ]
        [ Styled.text ("Published on the " ++ formatDate timestamp) ]


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
