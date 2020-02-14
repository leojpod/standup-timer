module Model exposing (CountDownState(..), Model, initModel, simpleConfig)


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
    | Ticking Bool Float
    | Completed


type alias Config =
    { speachTime : Float
    , allowedOverTime : Float
    }


simpleConfig : Int -> Config
simpleConfig baseTime =
    { speachTime = baseTime |> toFloat |> (*) 1000.0
    , allowedOverTime = (toFloat baseTime / 6) |> ceiling |> toFloat |> (*) 1000.0
    }


initModel : Maybe String -> Model
initModel =
    Maybe.andThen String.toInt
        >> Maybe.withDefault 60
        >> simpleConfig
        >> Model (Paused Nothing)
