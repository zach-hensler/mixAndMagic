module Main exposing (..)


import Browser
import Html exposing (Html, button, div, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)



-- MAIN


main =
  Browser.sandbox { init = init, update = update, view = view }



-- MODEL

type alias Model =
  { currentZone: Int
  , playerXPos: Int
  , playerYPos: Int
  , zone: List (List String)
  }


init : Model
init =
  { currentZone = 0
  , playerXPos = 1
  , playerYPos = 1
  , zone = [ ["-", "-", "-", "-", "-", "-", "-", "-"]
           , ["-", "", "", "", "", "", "", "-"]
           , ["-", "", "", "", "", "", "", "-"]
           , ["-", "", "", "", "", "", "", "-"]
           , ["-", "", "", "", "", "", "", "-"]
           , ["-", "", "", "", "", "", "", "-"]
           , ["-", "", "", "", "", "", "", "-"]
           , ["-", "-", "-", "-", "-", "-", "-", "-"]]
  }



-- UPDATE


type Msg
  = MovePlayerLeft
  | MovePlayerRight
  | MovePlayerUp
  | MovePlayerDown
  | AdvanceZone


update : Msg -> Model -> Model
update msg model =
  case msg of
    MovePlayerLeft ->
      { model | playerXPos =
        if isForbiddenSpace (model.playerXPos - 1) model.playerYPos
        then model.playerXPos
        else model.playerXPos - 1 }
    MovePlayerRight ->
      { model | playerXPos =
        if isForbiddenSpace (model.playerXPos + 1) model.playerYPos
        then model.playerXPos
        else model.playerXPos + 1}
    MovePlayerUp ->
      { model | playerYPos =
        if isForbiddenSpace model.playerXPos (model.playerYPos - 1)
        then model.playerYPos
        else model.playerYPos - 1}
    MovePlayerDown ->
      { model | playerYPos =
        if isForbiddenSpace model.playerXPos (model.playerYPos + 1)
        then model.playerYPos
        else model.playerYPos + 1}
    AdvanceZone ->
      { model | currentZone = model.currentZone + 1 }

isForbiddenSpace newPlayerXPos newPlayerYPos =
  if newPlayerXPos > 6 || newPlayerYPos > 6 || newPlayerXPos < 1 || newPlayerYPos < 1
  then True
  else False


-- VIEW

drawZoneRow: (Int, Int) -> Int -> List String -> Html Msg
drawZoneRow (playerXPos, playerYPos) rowIndex rowMap =
  div
    [ style "display" "flex"
    ] (List.indexedMap (drawZoneSquare (playerXPos, playerYPos) rowIndex) rowMap)

drawZoneSquare: (Int, Int) -> Int -> Int -> String -> Html Msg
drawZoneSquare (playerXPos, playerYPos) squareYPos squareXPos squareDefaultContent =
  span
      [ style "border" "solid black 1px"
      , style "padding" "5px"
      , style "width" "20px"
      , style "height" "20px"
      ] [
        if (playerXPos, playerYPos) == (squareXPos, squareYPos)
        then text "X"
        else text squareDefaultContent
      ]

view : Model -> Html Msg
view model =
  div
  [ style "width" "100%"
  , style "height" "100vh"
  , style "display" "flex"
  , style "flex-direction" "column"
  , style "justify-content" "center"
  , style "align-items" "center"
  ] [ div
      [ style "display" "flex"
      , style "flex-direction" "column"
      ] (List.indexedMap (drawZoneRow (model.playerXPos, model.playerYPos)) model.zone)
    , div
      [ style "margin" "10px 0"
      ][ button [ onClick MovePlayerLeft ] [ text "Left" ]
         , button [ onClick MovePlayerUp ] [ text "Up" ]
         , button [ onClick MovePlayerDown ] [ text "Down" ]
         , button [ onClick MovePlayerRight ] [ text "Right" ]
      ]
    ]
