module API.API exposing (ApiResponse, apiResponseDecoder)

import API.Post exposing (ForemPosts, postsDecoder)
import Json.Decode as Decode



-- Model


type alias ApiResponse =
    { posts : ForemPosts
    }



-- HTTP


apiResponseDecoder : Decode.Decoder ApiResponse
apiResponseDecoder =
    Decode.map ApiResponse postsDecoder
