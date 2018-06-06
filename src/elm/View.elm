module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Svg
import Svg.Path
import Svg.Attributes exposing (viewBox)


-- local imports

import Model exposing (Model)
import Update exposing (Msg)


view : Model -> Html Msg
view model =
    div []
        [ clockDisplay True 0.6542
        ]


clockDisplay : Bool -> Float -> Html Msg
clockDisplay isFillingUp percent =
    let
        classNames =
            "time-viewer "
                ++ (if isFillingUp then
                        "fc-red"
                    else
                        "fc-primary"
                   )
    in
        div [ class classNames ]
            [ Svg.svg [ viewBox "-1 -1 2 2" ]
                [ Svg.path
                    [ Svg.Attributes.stroke "none"
                    , Svg.Attributes.fill "currentColor"
                    , Svg.Path.pathToAttribute [ clockBlock isFillingUp percent ]
                    ]
                    []
                ]
            ]


clockBlock : Bool -> Float -> Svg.Path.Subpath
clockBlock isFillingUp percent =
    let
        arcType =
            if (percent > 0.5 && isFillingUp) || (percent < 0.5 && not isFillingUp) then
                Svg.Path.largestArc
            else
                Svg.Path.smallestArc
    in
        Svg.Path.subpath (Svg.Path.startAt ( 1, 0 ))
            Svg.Path.closed
            [ Svg.Path.arcTo ( 1, 1 )
                0
                ( arcType
                , if isFillingUp then
                    Svg.Path.clockwise
                  else
                    Svg.Path.antiClockwise
                )
                (percentToPoint percent)
            , Svg.Path.lineTo ( 0, 0 )
            ]


percentToPoint : Float -> ( Float, Float )
percentToPoint percent =
    ( cos (2 * pi * percent), sin (2 * pi * percent) )
