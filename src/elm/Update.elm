module Update exposing (Msg(..), update, subscriptions)

import Model exposing (Model, CountDownState(..))
import Time
import AnimationFrame


type Msg
    = ToggleTimer
    | Tick Time.Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.countdownState ) of
        ( ToggleTimer, Paused Nothing ) ->
            ( { model | countdownState = Ticking True model.config.speachTime }, Cmd.none )

        ( ToggleTimer, Paused (Just state) ) ->
            ( { model | countdownState = state }, Cmd.none )

        ( ToggleTimer, Ticking _ _ ) ->
            ( { model | countdownState = Paused <| Just model.countdownState }, Cmd.none )

        ( Tick diff, Paused _ ) ->
            Debug.log "WTH this is not supposed to happen ... let's ignore it" ( model, Cmd.none )

        ( Tick diff, Ticking isInTime timeLeft ) ->
            let
                newTimeLeft =
                    timeLeft - diff

                newCountDownState =
                    if newTimeLeft < 0 then
                        case isInTime of
                            True ->
                                Ticking False model.config.allowedOverTime

                            False ->
                                Paused Nothing
                        -- there is no state yet to mark the countdown as completed
                    else
                        Ticking isInTime newTimeLeft
            in
                ( { model | countdownState = newCountDownState }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.countdownState of
        Paused _ ->
            Sub.none

        Ticking _ _ ->
            AnimationFrame.diffs Tick
