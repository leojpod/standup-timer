module Model exposing (CountDownState(..), Model, initModel, simpleConfig)

import Time


type alias Model =
    { countdownState : CountDownState
    , config : Config
    }


{-| Represent the state of the current countdown.

  - Pause: The Maybe will be used to see if the countdown has been placed in pause (i.e. there is a state to restore) or just stopped (Nothing to restore)
  - Ticking: The boolean will indicate if the speaker is in time or running overtime

-}
type CountDownState
    = Paused (Maybe CountDownState)
    | Ticking Bool Time.Time
    | Completed


type alias Config =
    { speachTime : Time.Time
    , allowedOverTime : Time.Time
    }


simpleConfig : Int -> Config
simpleConfig baseTime =
    { speachTime = baseTime |> toFloat |> (*) Time.second
    , allowedOverTime = (toFloat baseTime / 6) |> ceiling |> toFloat |> (*) Time.second
    }


initModel : Maybe String -> Model
initModel =
    Maybe.andThen (String.toInt >> Result.toMaybe)
        >> Maybe.withDefault 60
        >> simpleConfig
        >> Model (Paused Nothing)
