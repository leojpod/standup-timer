module Main exposing (init, main)

-- local imports

import Html
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
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
