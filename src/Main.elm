module Main exposing (..)


import Browser
import Html exposing (Html, button, div, hr, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)



----------------------------
-- MAIN --------------------
----------------------------


main =
  Browser.sandbox { init = init, update = update, view = view }


----------------------------
-- CONSTANTS ---------------
----------------------------

maxPartySize: Int
maxPartySize = 3

----------------------------
-- MODEL -------------------
----------------------------

type alias Coordinates = (Int, Int)
type alias HeldItem = { name: String, description: String, numberAvailable: Int, numberOwned: Int }
type alias Character = { class: String, species: String, heldItem: Maybe HeldItem }

type ActiveView = Map | MainMenu | Bag | Party | Reserve | ItemAssignmentViewOpen HeldItem | Shop

type alias Zone =
  { borders: List Coordinates
  , entrance: Coordinates
  , exit: Coordinates
  , shop: Coordinates
  , width: Int
  , height: Int}

type alias Model =
  { playerCoordinates: Coordinates
  , currentZone: Zone
  , remainingZones: List Zone
  , defaultZone: Zone
  , activeView: ActiveView
  , bag: List HeldItem
  , party: List Character
  , reserve: List Character}

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
  , activeView = Map
  , bag =
    [ { name = "Enchanted Gloves", description = "All contact moves have a random secondary effect", numberAvailable = 1, numberOwned = 1 }
    , { name = "Protective Pendant", description = "Take 10% less damage from attacks", numberAvailable = 1, numberOwned = 1 }
    , { name = "Holy Hand-grenade", description = "Your first attack deals explosive damage and blinds foes", numberAvailable = 1, numberOwned = 1 }
    , { name = "Channeling Staff", description = "Your magic attacks take an extra turn to charge, but deal 3x damage", numberAvailable = 1, numberOwned = 1 }
    , { name = "Wooden Shield", description = "Take 20% less damage, but take 2x fire damage", numberAvailable = 1, numberOwned = 1 }
    , { name = "Hideous Hat", description = "A hat so ugly that enemies are sure to target you first", numberAvailable = 1, numberOwned = 1 }]
  , party =
    [ { class = "Mage", species = "Human", heldItem = Nothing }
    , { class = "Healer", species = "Elf", heldItem = Nothing }]
  , reserve = []}

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
  = Reset
  | MovePlayerLeft
  | MovePlayerRight
  | MovePlayerUp
  | MovePlayerDown
  | LeaveShop
  | OpenMenu
  | CloseMenu
  | OpenParty
  | CloseParty
  | OpenReserve
  | CloseReserve
  | OpenBag
  | CloseBag
  | MovePartyMemberToReserve Character
  | MoveReserveMemberToParty Character
  | AddNewPartyMember Character
  | OpenItemAssigment HeldItem
  | CloseItemAssignment
  | PerformItemAssignment Character HeldItem
  | ReturnAssignedItem Character


update: Msg -> Model -> Model
update msg model =
  case msg of
    Reset -> init
    MovePlayerLeft ->
      moveToNewSpace (Tuple.mapFirst (\int -> int - 1) model.playerCoordinates) model |> handleMapInteractions
    MovePlayerRight ->
      moveToNewSpace (Tuple.mapFirst (\int -> int + 1) model.playerCoordinates) model |> handleMapInteractions
    MovePlayerUp ->
      moveToNewSpace (Tuple.mapSecond (\int -> int - 1) model.playerCoordinates) model |> handleMapInteractions
    MovePlayerDown ->
      moveToNewSpace (Tuple.mapSecond (\int -> int + 1) model.playerCoordinates) model |> handleMapInteractions
    LeaveShop -> { model | activeView = Map }
    OpenMenu -> { model | activeView = MainMenu }
    CloseMenu -> { model | activeView = Map }
    OpenParty -> { model | activeView = Party }
    CloseParty -> { model | activeView = MainMenu }
    OpenReserve -> { model | activeView = Reserve }
    CloseReserve -> { model | activeView = MainMenu }
    OpenBag -> { model | activeView = Bag }
    CloseBag -> { model | activeView = MainMenu }
    MovePartyMemberToReserve character ->
      { model
      | party = List.filter (isNotSamePartyMember character) model.party
      , reserve = List.append model.reserve [character]}
    MoveReserveMemberToParty character ->
      if List.length model.party < maxPartySize
      then { model
      | reserve = List.filter (isNotSamePartyMember character) model.reserve
      , party = List.append model.party [character]}
      else model
    AddNewPartyMember character ->
      if List.length model.party >= maxPartySize
      then { model | reserve = List.append model.reserve [character] }
      else { model | party = List.append model.party [character] }
    OpenItemAssigment item ->
      { model | activeView = if item.numberAvailable > 0 then (ItemAssignmentViewOpen item) else Bag }
    CloseItemAssignment -> { model | activeView = Bag }
    PerformItemAssignment character item ->
      if (character.heldItem == Nothing)
      then assignItem character item model
      else (returnAssignedItem model character) |> (assignItem character item)
    ReturnAssignedItem member -> returnAssignedItem model member

assignItem: Character -> HeldItem -> Model -> Model
assignItem character item model =
  let newItem = { item | numberAvailable = item.numberAvailable - 1 } in
  { model
  | party = replacePartyMember { character | heldItem = Just newItem } { character | heldItem = Nothing } model.party
  , bag = replaceBagItem newItem item model.bag
  , activeView = Bag}

returnAssignedItem: Model -> Character -> Model
returnAssignedItem model character =
  case character.heldItem of
    Nothing -> model
    Just item -> { model
            | party = replacePartyMember { character | heldItem = Nothing } character model.party
            , bag = replaceBagItem { item | numberAvailable = item.numberAvailable + 1 } item model.bag
            , activeView = Bag}

replaceBagItem: HeldItem -> HeldItem -> List HeldItem -> List HeldItem
replaceBagItem newItem oldItem itemList =
  List.map (\i -> if i == oldItem then newItem else i) itemList

replacePartyMember: Character -> Character -> List Character -> List Character
replacePartyMember newMember oldMember memberList =
  List.map (\m -> if m == oldMember then newMember else m) memberList

isNotSamePartyMember: Character -> Character -> Bool
isNotSamePartyMember character1 character2 = not (character1 == character2)

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

enterShop model = { model | activeView = Shop }

----------------------------
-- VIEW --------------------
----------------------------

view : Model -> Html Msg
view model =
  div
  [ style "width" "100%"
  , style "height" "100vh"
  , style "display" "flex"
  , style "flex-direction" "row"
  , style "justify-content" "center"
  , style "align-items" "center"
  , style "text-align" "center"
  ]
  [ drawZoneAndControls model
  , drawMenu model
  , drawBag model
  , drawItemAssignment model
  , drawParty model
  , drawReserve model
  , drawAddNewMemberButton model
  ]

drawZoneAndControls: Model -> Html Msg
drawZoneAndControls model =
  div []
    [ div
      [ style "display" "flex"
      , style "flex-direction" "column"
      ] (List.map (drawZoneRow model) (List.range 0 model.currentZone.height))
    , div
      [ style "margin" "10px 0"
      , style "display" "flex"
      , style "justify-content" "space-around" ]
      [ button [ onClick MovePlayerLeft ] [ text "Left" ]
      , button [ onClick MovePlayerUp ] [ text "Up" ]
      , button [ onClick MovePlayerDown ] [ text "Down" ]
      , button [ onClick MovePlayerRight ] [ text "Right" ] ]
    , div [ style "display" (if model.activeView == Shop then "block" else "none") ]
        [ text "You are in the shop"
      , button [ onClick LeaveShop ] [ text "Leave Shop" ] ] ]

drawZoneRow: Model -> Int -> Html Msg
drawZoneRow model yCoordinate =
  div[style "display" "flex"](List.map (drawZoneSquare model yCoordinate) (List.range 0 model.currentZone.width))

drawZoneSquare: Model -> Int -> Int -> Html Msg
drawZoneSquare model yCoordinate xCoordinate =
  div
    [ style "border" "solid black 1px"
    , style "padding" "5px"
    , style "width" "40px"
    , style "height" "40px"
    ]
    [ if (xCoordinate, yCoordinate) == model.playerCoordinates then text "P"
      else if (xCoordinate, yCoordinate) == (model.currentZone.shop) then text "S"
      else if (xCoordinate, yCoordinate) == model.currentZone.exit then text "X"
      else if List.member (xCoordinate, yCoordinate) model.currentZone.borders then text "*"
      else text " "
    ]

drawMenu: Model -> Html Msg
drawMenu model =
  div []
    [ button
      [ onClick OpenMenu
      , style "margin" "5px"
      , style "display" (if model.activeView == MainMenu then "none" else "block")] [ text "Open Menu" ]
    , div
      [ style "border" "solid black 1px"
      , style "margin" "5px"
      , style "display" (if model.activeView == MainMenu then "flex" else "none")
      , style "flex-direction" "column"
      , style "align-items" "center"]
      [ div [ style "padding" "5px 10px" ] [ text "Menu" ]
      , hr [ style "width" "70%", style "color" "lightgray" ] []
      , div [ style "padding" "5px 10px" ] [ button [ onClick OpenParty ] [ text "Party" ] ]
      , div [ style "padding" "5px 10px" ] [ button [ onClick OpenReserve ] [ text "Reserve" ] ]
      , div [ style "padding" "5px 10px" ] [ button [ onClick OpenBag ] [ text "Bag" ] ]
      , div [ style "padding" "5px 10px" ] [ button [ onClick CloseMenu ] [ text "Close" ] ]
      ]
    ]

drawBag: Model -> Html Msg
drawBag model =
  div
    [ style "border" "solid black 1px"
    , style "margin" "5px"
    , style "display" (if (model.activeView == Bag) then "flex" else "none" )
    , style "flex-direction" "column"]
  [ div [ style "padding" "5px 10px" ] [text "Bag"]
  , div
    [ style "display" "flex"
    , style "flex-direction" "column"] (List.map drawBagItem model.bag)
  , button [ onClick CloseBag, style "margin" "5px 10px" ] [ text "Close" ] ]

drawBagItem: HeldItem -> Html Msg
drawBagItem bagItem =
  div
    [ style "padding" "5px 10px"]
    [ hr [ style "width" "85%", style "color" "lightgray" ] []
    , div [ style "font-weight" "bold" ] [text bagItem.name]
    , div
      [ style "display" "flex"]
      [ div [ style "width" "70%" ] [ text bagItem.description ]
      , div [ style "width" "30%" ] [ text (String.fromInt bagItem.numberAvailable ++ "/" ++ String.fromInt bagItem.numberOwned) ]]
    , button
      [ style "width" "100%"
      , style "display" (if (bagItem.numberAvailable > 0) then "block" else "none")
      , onClick (OpenItemAssigment bagItem) ]
      [ text "Assign" ]]

drawItemAssignment: Model -> Html Msg
drawItemAssignment model =
  case model.activeView of
    ItemAssignmentViewOpen item ->
      div
        [ style "border" "solid black 1px"
        , style "margin" "5px"
        , style "flex-direction" "column"]
        [ div [ style "padding" "5px 10px" ] [text ("Assign " ++ item.name ++ " to:") ]
        , div
          [ style "display" "flex"
          , style "flex-direction" "column"] (List.map (drawItemAssignmentPartyMember item) model.party)
          , button [ onClick CloseItemAssignment, style "margin" "5px 10px" ] [ text "Close" ]]
    _ -> div [ style "display" "none" ] []

drawItemAssignmentPartyMember: HeldItem -> Character -> Html Msg
drawItemAssignmentPartyMember item partyMember =
  button
    [onClick (PerformItemAssignment partyMember item)] [ text (partyMember.species ++ partyMember.class) ]

drawParty: Model -> Html Msg
drawParty model =
  div
    [ style "border" "solid black 1px"
    , style "margin" "5px"
    , style "display" (if (model.activeView == Party) then "flex" else "none" )
    , style "flex-direction" "column"]
  [ div [ style "padding" "5px 10px" ] [text "Party"]
  , div
    [ style "display" "flex"
    , style "flex-direction" "column"] (List.map drawPartyMember model.party)
  , button [ onClick CloseParty, style "margin" "5px 10px" ] [ text "Close" ]]

drawPartyMember: Character -> Html Msg
drawPartyMember partyMember =
  div
    [ style "padding" "5px 10px"]
    [ hr [ style "width" "85%", style "color" "lightgray" ] []
    , div [ style "font-weight" "bold" ] [text (partyMember.species ++ " " ++ partyMember.class) ]
    , drawPartyMemberHeldItem partyMember.heldItem
    , div
      [ style "display" (if (partyMember.heldItem == Nothing) then "none" else "block")]
      [ button [ onClick (ReturnAssignedItem partyMember) ] [text "Return Item"] ]
    , div [] [ button [ onClick (MovePartyMemberToReserve partyMember) ] [ text "Move to Reserve" ] ]]

drawPartyMemberHeldItem: Maybe HeldItem -> Html Msg
drawPartyMemberHeldItem bagItem =
  case bagItem of
    Nothing -> div [ style "display" "none" ] []
    Just item -> div [] [text ("holding: " ++ item.name)]

drawReserve: Model -> Html Msg
drawReserve model =
  div
    [ style "border" "solid black 1px"
    , style "margin" "5px"
    , style "display" (if (model.activeView == Reserve) then "flex" else "none" )
    , style "flex-direction" "column"]
  [ div [ style "padding" "5px 10px" ] [text "Reserve"]
  , div
    [ style "display" "flex"
    , style "flex-direction" "column"] (List.map drawReserveMember model.reserve)
  , button [ onClick CloseReserve, style "margin" "5px 10px" ] [ text "Close" ] ]

drawAddNewMemberButton: Model -> Html Msg
drawAddNewMemberButton model =
  div []
    [ button
      [ onClick (AddNewPartyMember
        { class = "Mage"
        , species = "Wolf"
        , heldItem = Nothing } )]
      [ text "Add new member" ]]

drawReserveMember: Character -> Html Msg
drawReserveMember reserveMember =
  div
    [ style "padding" "5px 10px"]
    [ hr [ style "width" "85%", style "color" "lightgray" ] []
    , div [ style "font-weight" "bold" ] [text (reserveMember.species ++ " " ++ reserveMember.class) ]
    , drawReserveMemberHeldItem reserveMember.heldItem
    , div [] [ button [ onClick (MoveReserveMemberToParty reserveMember) ] [ text "Move to Party" ] ]]

drawReserveMemberHeldItem: Maybe HeldItem -> Html Msg
drawReserveMemberHeldItem bagItem =
  case bagItem of
    Nothing -> div [ style "display" "none" ] []
    Just item -> div [] [text ("holding: " ++ item.name)]
