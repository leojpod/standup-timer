module View exposing (clockBlock, clockDisplay, percentToPoint, view)

-- local imports

import Html exposing (Html, audio, button, div, h1, h2, text)
import Html.Attributes exposing (autoplay, class, src)
import Html.Events exposing (onClick)
import Json.Decode
import LowLevel.Command
import Model exposing (CountDownState(..), Model)
import Round
import SubPath
import Svg
import Svg.Attributes exposing (viewBox)
import Update exposing (Msg(..))


inSeconds : Float -> Float
inSeconds =
    (*) 0.001


view : Model -> Html Msg
view model =
    let
        headerMessage =
            case model.countdownState of
                Completed ->
                    "Stop talking"

                Paused Nothing ->
                    "Get Ready"

                Paused _ ->
                    "Hold on for a moment"

                Ticking True _ ->
                    "We're listening"

                Ticking False _ ->
                    "Wrap up quicker!"

        bottomMessage =
            case model.countdownState of
                Completed ->
                    "Someone else's turn"

                Paused Nothing ->
                    "On your mark"

                Paused (Just (Ticking _ timeLeft)) ->
                    String.fromInt <| ceiling <| inSeconds timeLeft

                Paused (Just Completed) ->
                    ""

                Paused (Just (Paused _)) ->
                    ""

                Ticking _ timeLeft ->
                    String.fromInt <| ceiling <| inSeconds timeLeft

        ( warningMode, percentLeft ) =
            case model.countdownState of
                Completed ->
                    ( True, 0 )

                Paused Nothing ->
                    -- this is just an arbitrary number to show the piece of UI
                    ( False, 0.234 )

                Paused (Just (Ticking isInTime timeLeft)) ->
                    if isInTime then
                        ( False, (model.config.speachTime - timeLeft) / model.config.speachTime )

                    else
                        ( True, (model.config.allowedOverTime - timeLeft) / model.config.allowedOverTime )

                Paused (Just Completed) ->
                    ( True, 0 )

                Paused (Just (Paused _)) ->
                    ( True, 0 )

                Ticking True timeLeft ->
                    ( False, (model.config.speachTime - timeLeft) / model.config.speachTime )

                Ticking False timeLeft ->
                    ( True, (model.config.allowedOverTime - timeLeft) / model.config.allowedOverTime )
    in
    div
        [ class "grid-wrapper grid-wrapper-stepped"
        , onClick
            (case model.countdownState of
                Completed ->
                    ResetCountdown

                Paused Nothing ->
                    ToggleTimer

                Paused (Just _) ->
                    ResetCountdown

                Ticking _ _ ->
                    ResetCountdown
            )
        ]
        [ div [ class "grid" ]
            [ div [ class "grid__col--1-of-2 grid__col--centered" ]
                [ div [ class " flex flex-column justify-center items-center" ]
                    [ h1 [ class "fs4" ]
                        [ text headerMessage ]
                    , clockDisplay warningMode percentLeft
                    , h2 [ class "fs2" ]
                        [ text bottomMessage ]
                    , button
                        [ class "r-btn r-btn-primary r-btn-large"
                        , Html.Events.custom "click" <|
                            Json.Decode.succeed { message = ToggleTimer, stopPropagation = True, preventDefault = True }
                        ]
                        [ text <|
                            case model.countdownState of
                                Ticking _ _ ->
                                    "Pause"

                                Paused Nothing ->
                                    "Start"

                                Paused (Just _) ->
                                    "Resume"

                                Completed ->
                                    "Reset"
                        ]
                    , audio
                        [ src <|
                            if warningMode then
                                if percentLeft < 0.0001 then
                                    "%PUBLIC_URL%/audio/flat-line-beep.mp3"

                                else
                                    "%PUBLIC_URL%/audio/short-beep.mp3"

                            else
                                ""
                        , autoplay True
                        , class "hidden"
                        ]
                        []
                    ]
                ]
            ]
        ]


clockDisplay : Bool -> Float -> Html Msg
clockDisplay isFillingUp percent =
    let
        classNames =
            "time-viewer "
                ++ (if isFillingUp then
                        "fc-red"

                    else
                        "fc-teal"
                   )
    in
    div [ class classNames ]
        [ Svg.svg [ viewBox "-1 -1 2 2" ]
            [ SubPath.element (clockBlock isFillingUp percent)
                [ Svg.Attributes.stroke "none"
                , Svg.Attributes.fill "currentColor"
                ]
            ]
        ]


clockBlock : Bool -> Float -> SubPath.SubPath
clockBlock isFillingUp percent =
    let
        arcType =
            if (percent > 0.5 && isFillingUp) || (percent < 0.5 && not isFillingUp) then
                LowLevel.Command.largestArc

            else
                LowLevel.Command.smallestArc
    in
    -- [ Segment.line ( 0, 0 ) ( 1, 0 )
    [ LowLevel.Command.arcTo
        [ { radii = ( 1, 1 )
          , xAxisRotate = 0
          , arcFlag = arcType
          , direction =
                if not isFillingUp then
                    LowLevel.Command.clockwise

                else
                    LowLevel.Command.counterClockwise
          , target = percentToPoint percent
          }
        ]
    , LowLevel.Command.lineTo [ ( 0, 0 ) ]
    ]
        |> SubPath.with (LowLevel.Command.moveTo ( 1, 0 ))


percentToPoint : Float -> ( Float, Float )
percentToPoint percent =
    ( Round.roundNum 8 <| cos (2 * pi * percent), Round.roundNum 8 <| sin (2 * pi * percent) )
