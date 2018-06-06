module Update exposing (Msg, update, subscriptions)

import Model exposing (Model)


type Msg
    = Start
    | Stop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions =
    always Sub.none
