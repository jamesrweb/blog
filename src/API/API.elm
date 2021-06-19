module API.API exposing (ApiResponse, apiResponseDecoder)

import API.Post exposing (Posts, postsDecoder)
import Json.Decode as Decode



-- Model


type alias ApiResponse =
    { posts : Posts
    }



-- HTTP


apiResponseDecoder : Decode.Decoder ApiResponse
apiResponseDecoder =
    Decode.map ApiResponse
        (Decode.field "posts" <| postsDecoder)
