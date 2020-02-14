module Main exposing (init, main)

-- local imports

import Browser
import Model exposing (Model, initModel)
import Update exposing (Msg, subscriptions, update)
import View exposing (view)



---- INIT ----


init : Maybe String -> ( Model, Cmd Msg )
init customTime =
    ( initModel customTime, Cmd.none )



---- PROGRAM ----


main : Program (Maybe String) Model Msg
main =
    Browser.document
        { view = view >> List.singleton >> Browser.Document "Standup timer"
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
