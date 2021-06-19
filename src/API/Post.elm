module API.Post exposing (Post, Posts, postDecoder, postsDecoder, viewPosts)

import Date
import Html.Styled as Styled
import Html.Styled.Attributes as Attributes
import Iso8601
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Styles
import Time



-- Model


type alias Post =
    { bodyMarkdown : String
    , canonicalUrl : String
    , commentsCount : Int
    , coverImage : String
    , description : String
    , flareTag : ForemFlareTag
    , id : Int
    , organization : ForemOrganisation
    , pageViewsCount : Int
    , path : String
    , positiveReactionsCount : Int
    , publicReactionsCount : Int
    , published : Bool
    , publishedAt : String
    , publishedTimestamp : String
    , readingTimeMinutes : Int
    , slug : String
    , tagList : List String
    , title : String
    , typeOf : String
    , url : String
    , user : ForemUser
    }


type alias Posts =
    List Post


type alias ForemUser =
    { githubUsername : String
    , name : String
    , profileImage : String
    , profileImage90 : String
    , twitterUsername : String
    , username : String
    , websiteUrl : String
    }


type alias ForemOrganisation =
    { name : String
    , profileImage : String
    , profileImage90 : String
    , slug : String
    , username : String
    }


type alias ForemFlareTag =
    { bgColorHex : String
    , name : String
    , textColorHex : String
    }



-- View


viewPosts : List Post -> Styled.Html msg
viewPosts posts =
    case posts of
        [] ->
            Styled.text "No posts are currently available"

        _ ->
            Styled.ul [ Styles.postList ] (List.map viewPost posts)


viewPost : Post -> Styled.Html msg
viewPost post =
    Styled.li [ Styles.post ] [ viewPostLink post ]


viewPostLink : Post -> Styled.Html msg
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


postDecoder : Decode.Decoder Post
postDecoder =
    Decode.succeed Post
        |> Pipeline.required "body_markdown" Decode.string
        |> Pipeline.required "canonical_url" Decode.string
        |> Pipeline.required "comments_count" Decode.int
        |> Pipeline.required "cover_image" Decode.string
        |> Pipeline.required "description" Decode.string
        |> Pipeline.required "flare_tag" foremFlareTagDecoder
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "organization" foremOrganizationDecoder
        |> Pipeline.required "page_views_count" Decode.int
        |> Pipeline.required "path" Decode.string
        |> Pipeline.required "positive_reactions_count" Decode.int
        |> Pipeline.required "public_reactions_count" Decode.int
        |> Pipeline.required "published" Decode.bool
        |> Pipeline.required "published_at" Decode.string
        |> Pipeline.required "published_timestamp" Decode.string
        |> Pipeline.required "reading_time_minutes" Decode.int
        |> Pipeline.required "slug" Decode.string
        |> Pipeline.required "tag_list" (Decode.list Decode.string)
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "type_of" Decode.string
        |> Pipeline.required "url" Decode.string
        |> Pipeline.required "user" foremUserDecoder


postsDecoder : Decode.Decoder Posts
postsDecoder =
    Decode.list postDecoder


foremUserDecoder : Decode.Decoder ForemUser
foremUserDecoder =
    Decode.map7 ForemUser
        (Decode.field "github_username" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "profile_image" Decode.string)
        (Decode.field "profile_image_90" Decode.string)
        (Decode.field "twitter_username" Decode.string)
        (Decode.field "username" Decode.string)
        (Decode.field "website_url" Decode.string)


foremOrganizationDecoder : Decode.Decoder ForemOrganisation
foremOrganizationDecoder =
    Decode.map5 ForemOrganisation
        (Decode.field "name" Decode.string)
        (Decode.field "profile_image" Decode.string)
        (Decode.field "profile_image_90" Decode.string)
        (Decode.field "slug" Decode.string)
        (Decode.field "username" Decode.string)


foremFlareTagDecoder : Decode.Decoder ForemFlareTag
foremFlareTagDecoder =
    Decode.map3 ForemFlareTag
        (Decode.field "bg_color_hex" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "text_color_hex" Decode.string)
