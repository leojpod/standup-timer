module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onWithOptions)
import Svg
import Svg.Path
import Svg.Attributes exposing (viewBox)
import Json.Decode
import Time


-- local imports

import Model exposing (Model, CountDownState(..))
import Update exposing (Msg(..))


view : Model -> Html Msg
view model =
    let
        headerMessage =
            case model.countdownState of
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
                Paused Nothing ->
                    "On your mark"

                Paused (Just (Ticking _ timeLeft)) ->
                    (toString <| ceiling <| Time.inSeconds timeLeft)

                Paused (Just (Paused _)) ->
                    Debug.crash "this should never happen!"

                Ticking _ timeLeft ->
                    (toString <| ceiling <| Time.inSeconds timeLeft)

        ( warningMode, percentLeft ) =
            case model.countdownState of
                Paused Nothing ->
                    ( False, 0.6542 )

                -- this is just an arbitrary number to show the piece of UI
                Paused (Just (Ticking isInTime timeLeft)) ->
                    if isInTime then
                        ( False, (model.config.speachTime - timeLeft) / model.config.speachTime )
                    else
                        ( True, (model.config.allowedOverTime - timeLeft) / model.config.allowedOverTime )

                Paused (Just (Paused _)) ->
                    Debug.crash "this should never happen!"

                Ticking True timeLeft ->
                    ( False, (model.config.speachTime - timeLeft) / model.config.speachTime )

                Ticking False timeLeft ->
                    ( True, (model.config.allowedOverTime - timeLeft) / model.config.allowedOverTime )
    in
        div
            [ class "grid-wrapper grid-wrapper-stepped"
            , onClick
                (case model.countdownState of
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
                            , onWithOptions "click"
                                { stopPropagation = True, preventDefault = True }
                                (Json.Decode.succeed ToggleTimer)
                            ]
                            [ text <|
                                case model.countdownState of
                                    Ticking _ _ ->
                                        "Pause"

                                    Paused Nothing ->
                                        "Start"

                                    Paused (Just _) ->
                                        "Resume"
                            ]
                        , audio [ src "/audio/short-beep.mp3", autoplay True, class "hidden" ] []
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
