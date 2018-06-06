module Main exposing (..)

import Html


-- local imports

import Model exposing (Model)
import View exposing (view)
import Update exposing (Msg, update, subscriptions)


---- INIT ----


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
