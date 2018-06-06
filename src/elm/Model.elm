module Model exposing (Model, CountDownState(..), initModel)

import Time


type alias Model =
    { config : Config
    , countdownState : CountDownState
    }


{-| Represent the state of the current countdown.

  - Pause: The Maybe will be used to see if the countdown has been placed in pause (i.e. there is a state to restore) or just stopped (Nothing to restore)
  - Ticking: The boolean will indicate if the speaker is in time or running overtime

-}
type CountDownState
    = Paused (Maybe CountDownState)
    | Ticking Bool Time.Time


type alias Config =
    { speachTime : Time.Time
    , allowedOverTime : Time.Time
    }


basicConfig : Config
basicConfig =
    { speachTime = 30.0 * Time.second
    , allowedOverTime = 5.0 * Time.second
    }


initModel : Model
initModel =
    { config = basicConfig
    , countdownState = Paused Nothing
    }
