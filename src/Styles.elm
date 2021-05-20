module Styles exposing (..)

import Css
import Css.Global
import Css.Reset as Reset
import Html.Styled as Styled exposing (Attribute)
import Html.Styled.Attributes as Attributes


reset : List (Styled.Html msg)
reset =
    [ Reset.meyerV2
    , Reset.borderBoxV201408
    ]


global : Styled.Html msg
global =
    Css.Global.global
        [ Css.Global.selector "html"
            [ Css.fontSize (Css.px 16)
            ]
        ]


container : Attribute msg
container =
    Attributes.css
        [ Css.padding (Css.rem 2)
        , Css.fontFamily Css.sansSerif
        , Css.fontSize (Css.rem 1.25)
        , Css.maxWidth (Css.rem 45)
        , Css.margin2 (Css.rem 0) Css.auto
        ]


header : Attribute msg
header =
    Attributes.css
        [ Css.padding2 (Css.rem 3) (Css.rem 0)
        , Css.textAlign Css.center
        , Css.fontSize (Css.rem 3)
        ]


link : Attribute msg
link =
    Attributes.css
        [ Css.color Css.currentColor
        , Css.textDecoration Css.none
        , Css.display Css.inlineBlock
        ]


postList : Attribute msg
postList =
    Attributes.css
        [ Css.listStyle Css.none
        , Css.padding (Css.rem 0)
        ]


post : Attribute msg
post =
    Attributes.css
        [ Css.padding2 (Css.rem 2) (Css.rem 2)
        , Css.borderRadius (Css.rem 0.25)
        , Css.boxShadow5 (Css.rem 0) (Css.rem 0.25) (Css.rem 0.5) (Css.rem 0) (Css.rgba 0 0 0 0.2)
        , Css.marginBottom (Css.rem 1.5)
        ]


postTitle : Attribute msg
postTitle =
    Attributes.css
        [ Css.fontSize (Css.rem 1.5)
        , Css.marginBottom (Css.rem 0.5)
        ]


time : Attribute msg
time =
    Attributes.css
        [ Css.fontSize (Css.rem 1)
        ]
