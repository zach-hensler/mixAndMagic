module Main exposing (..)


import Browser
import Html exposing (Html, button, div, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)



-- MAIN


main =
  Browser.sandbox { init = init, update = update, view = view }



-- MODEL
type alias Coordinates = (Int, Int)

type alias Zone =
  { borders: List Coordinates
  , entrance: Coordinates
  , exit: Coordinates
  , shop: Coordinates
  , width: Int,
  height: Int }

type alias Model =
  { playerXPos: Int
  , playerYPos: Int
  , currentZone: Zone
  , remainingZones: List Zone
  , defaultZone: Zone
  }


init : Model
init =
  { playerXPos = 1
  , playerYPos = 1
  , currentZone =
    { borders = [(5,0), (4, 0), (5,1)]
    , entrance = (0, 0)
    , exit = (5, 5)
    , shop = (3, 3)
    , width = 5
    , height = 5 }
  , remainingZones = []
  , defaultZone =
    { borders = [(5,0), (4, 0), (5,1)]
    , entrance = (0, 0)
    , exit = (5, 5)
    , shop = (3, 3)
    , width = 5
    , height = 5 }
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
        if isForbiddenSpace model (model.playerXPos - 1) model.playerYPos
        then model.playerXPos
        else model.playerXPos - 1 }
    MovePlayerRight ->
      { model | playerXPos =
        if isForbiddenSpace model (model.playerXPos + 1) model.playerYPos
        then model.playerXPos
        else model.playerXPos + 1 }
    MovePlayerUp ->
      { model | playerYPos =
        if isForbiddenSpace model model.playerXPos (model.playerYPos - 1)
        then model.playerYPos
        else model.playerYPos - 1 }
    MovePlayerDown ->
      { model | playerYPos =
        if isForbiddenSpace model model.playerXPos (model.playerYPos + 1)
        then model.playerYPos
        else model.playerYPos + 1 }
    AdvanceZone ->
      { model
      | currentZone = List.head model.remainingZones |> Maybe.withDefault model.defaultZone
      , remainingZones = List.tail model.remainingZones |> Maybe.withDefault [] }

isForbiddenSpace: Model -> Int -> Int -> Bool
isForbiddenSpace model newPlayerXPos newPlayerYPos =
  if newPlayerXPos > model.currentZone.width
  || newPlayerYPos > model.currentZone.height
  || newPlayerXPos < 0
  || newPlayerYPos < 0
  || List.member (newPlayerXPos, newPlayerYPos) model.currentZone.borders
  then True
  else False


-- VIEW

drawZoneRow: Model -> Int -> Html Msg
drawZoneRow model yCoordinate =
  div[style "display" "flex"](List.map (drawZoneSquare model yCoordinate) (List.range 0 model.currentZone.width))

drawZoneSquare: Model -> Int -> Int -> Html Msg
drawZoneSquare model yCoordinate xCoordinate =
  div
    [ style "border" "solid black 1px"
    , style "padding" "5px"
    , style "width" "20px"
    , style "height" "20px"
    ]
    [ if (xCoordinate, yCoordinate) == (model.playerXPos, model.playerYPos) then text "P"
      else if (xCoordinate, yCoordinate) == (model.currentZone.shop) then text "S"
      else if (xCoordinate, yCoordinate) == model.currentZone.exit then text "X"
      else if List.member (xCoordinate, yCoordinate) model.currentZone.borders then text "*"
      else text " "
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
      ] (List.map (drawZoneRow model) (List.range 0 model.currentZone.height))
    , div
      [ style "margin" "10px 0"
      ][ button [ onClick MovePlayerLeft ] [ text "Left" ]
         , button [ onClick MovePlayerUp ] [ text "Up" ]
         , button [ onClick MovePlayerDown ] [ text "Down" ]
         , button [ onClick MovePlayerRight ] [ text "Right" ]
      ]
    ]
