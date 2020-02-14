module Update exposing (Msg(..), subscriptions, update)

import Browser.Events
import Model exposing (CountDownState(..), Model)


type Msg
    = ToggleTimer
    | ResetCountdown
    | Tick Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.countdownState ) of
        ( ToggleTimer, Completed ) ->
            ( { model | countdownState = Ticking True model.config.speachTime }, Cmd.none )

        ( ToggleTimer, Paused Nothing ) ->
            ( { model | countdownState = Ticking True model.config.speachTime }, Cmd.none )

        ( ToggleTimer, Paused (Just state) ) ->
            ( { model | countdownState = state }, Cmd.none )

        ( ToggleTimer, Ticking _ _ ) ->
            ( { model | countdownState = Paused <| Just model.countdownState }, Cmd.none )

        ( Tick _, Completed ) ->
            -- this should never happen so let's ignore it
            ( model, Cmd.none )

        ( Tick _, Paused _ ) ->
            -- this should never happen so let's ignore it
            ( model, Cmd.none )

        ( Tick diff, Ticking isInTime timeLeft ) ->
            let
                newTimeLeft =
                    timeLeft - diff

                newCountDownState =
                    if newTimeLeft < 0 then
                        if isInTime then
                            Ticking False model.config.allowedOverTime

                        else
                            Completed
                        -- there is no state yet to mark the countdown as completed

                    else
                        Ticking isInTime newTimeLeft
            in
            ( { model | countdownState = newCountDownState }, Cmd.none )

        ( ResetCountdown, _ ) ->
            ( { model | countdownState = Paused Nothing }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.countdownState of
        Paused _ ->
            Sub.none

        Completed ->
            Sub.none

        Ticking _ _ ->
            Browser.Events.onAnimationFrameDelta Tick
