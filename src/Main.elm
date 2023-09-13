module Main exposing (..)


import Browser
import Html exposing (Html, button, div, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)



----------------------------
-- MAIN --------------------
----------------------------


main =
  Browser.sandbox { init = init, update = update, view = view }



----------------------------
-- MODEL -------------------
----------------------------

type alias Coordinates = (Int, Int)

type alias Zone =
  { borders: List Coordinates
  , entrance: Coordinates
  , exit: Coordinates
  , shop: Coordinates
  , width: Int,
  height: Int }

type alias Model =
  { playerCoordinates: Coordinates
  , currentZone: Zone
  , remainingZones: List Zone
  , defaultZone: Zone
  , playerInShop: Bool }

init : Model
init =
  { playerCoordinates = (1, 1)
  , currentZone =
    { borders = [(5,0), (4, 0), (5,1)]
    , entrance = (0, 0)
    , exit = (5, 5)
    , shop = (3, 3)
    , width = 5
    , height = 5 }
  , remainingZones = [finalZone]
  , defaultZone = finalZone
  , playerInShop = False }

finalZone: Zone
finalZone =
  { borders =
    [ (0, 0), (1, 0), (2, 0), (3, 0), (4, 0)
    , (0, 1), (0, 2), (0, 3), (0, 4)
    , (4, 1), (4, 2), (4, 3), (4, 4)
    , (0, 4), (1, 4), (2, 4), (3, 4), (4, 4)]
  , entrance = (2, 2)
  , exit = (5, 5)
  , shop = (5, 5)
  , width = 4
  , height = 4}


----------------------------
-- UPDATE ------------------
----------------------------


type Msg
  = MovePlayerLeft
  | MovePlayerRight
  | MovePlayerUp
  | MovePlayerDown
  | LeaveShop


update: Msg -> Model -> Model
update msg model =
  case msg of
    MovePlayerLeft ->
      moveToNewSpace (Tuple.mapFirst (\int -> int - 1) model.playerCoordinates) model |> handleMapInteractions
    MovePlayerRight ->
      moveToNewSpace (Tuple.mapFirst (\int -> int + 1) model.playerCoordinates) model |> handleMapInteractions
    MovePlayerUp ->
      moveToNewSpace (Tuple.mapSecond (\int -> int - 1) model.playerCoordinates) model |> handleMapInteractions
    MovePlayerDown ->
      moveToNewSpace (Tuple.mapSecond (\int -> int + 1) model.playerCoordinates) model |> handleMapInteractions
    LeaveShop -> { model | playerInShop = False }

moveToNewSpace: (Int, Int) -> Model -> Model
moveToNewSpace newPlayerCoordinates model = { model | playerCoordinates =
  if isForbiddenSpace model newPlayerCoordinates
  then model.playerCoordinates
  else newPlayerCoordinates }

isForbiddenSpace: Model -> (Int, Int) -> Bool
isForbiddenSpace model (newPlayerXPos, newPlayerYPos) =
  if newPlayerXPos > model.currentZone.width
  || newPlayerYPos > model.currentZone.height
  || newPlayerXPos < 0
  || newPlayerYPos < 0
  || List.member (newPlayerXPos, newPlayerYPos) model.currentZone.borders
  then True
  else False

handleMapInteractions: Model -> Model
handleMapInteractions model =
  if model.playerCoordinates == model.currentZone.exit then advanceZone model
  else if model.playerCoordinates == model.currentZone.shop then enterShop model
  else model

advanceZone: Model -> Model
advanceZone model =
  let newZone = List.head model.remainingZones |> Maybe.withDefault model.defaultZone in
  { model
  | currentZone = newZone
  , remainingZones = List.tail model.remainingZones |> Maybe.withDefault []
  , playerCoordinates = newZone.entrance }

enterShop model = { model | playerInShop = True }

----------------------------
-- VIEW --------------------
----------------------------

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
    [ if (xCoordinate, yCoordinate) == model.playerCoordinates then text "P"
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
  ]
  [ div
    [ style "display" "flex"
    , style "flex-direction" "column"
    ] (List.map (drawZoneRow model) (List.range 0 model.currentZone.height))
  , div
    [ style "margin" "10px 0"
    ][ button [ onClick MovePlayerLeft ] [ text "Left" ]
     , button [ onClick MovePlayerUp ] [ text "Up" ]
     , button [ onClick MovePlayerDown ] [ text "Down" ]
     , button [ onClick MovePlayerRight ] [ text "Right" ] ]
  , div [ style "visibility" (if model.playerInShop then "visible" else "hidden") ]
    [ text "You are in the shop"
    , button [ onClick LeaveShop ] [ text "Leave Shop" ] ]
  ]
