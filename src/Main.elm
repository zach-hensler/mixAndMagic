module Main exposing (..)


import Browser
import Html exposing (Html, button, div, h3, h4, hr, p, span, text)
import Html.Attributes exposing (disabled, style)
import Html.Events exposing (onClick)
import Map
import Items
import Battle
import Characters



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

type ActiveView
  = Map
  | MainMenu
  | Bag
  | Party
  | Reserve
  | ItemAssignmentViewOpen Items.HeldItem
  | Shop (List Items.ShopItem)
  | Battle (List Battle.Enemy)


type alias Model =
  { playerCoordinates: Coordinates
  , dungeon1Complete: Bool
  , dungeon2Complete: Bool
  , dungeon3Complete: Bool
  , currentMap: Map.Map
  , activeView: ActiveView
  , money: Int
  , bag: List Items.HeldItem
  , party: List Characters.Character
  , reserve: List Characters.Character}

init : Model
init =
  { playerCoordinates = (Map.hubMap False False False).entrance
  , dungeon1Complete = False
  , dungeon2Complete = False
  , dungeon3Complete = False
  , currentMap = Map.hubMap False False False
  , activeView = Map
  , money = 20
  , bag =
    [ { name = "Enchanted Gloves", description = "All contact moves have a random secondary effect", numberAvailable = 0, numberOwned = 0 }
    , { name = "Protective Pendant", description = "Take 10% less damage from attacks", numberAvailable = 0, numberOwned = 0 }
    , { name = "Holy Hand-grenade", description = "Your first attack deals explosive damage and blinds foes", numberAvailable = 0, numberOwned = 0 }
    , { name = "Channeling Staff", description = "Your magic attacks take an extra turn to charge, but deal 3x damage", numberAvailable = 0, numberOwned = 0 }
    , { name = "Wooden Shield", description = "Take 20% less damage, but take 2x fire damage", numberAvailable = 0, numberOwned = 0 }
    , { name = "Hideous Hat", description = "A hat so ugly that enemies are sure to target you first", numberAvailable = 0, numberOwned = 0 }]
  , party =
    [ { class = "Mage", species = "Human", heldItem = Nothing }
    , { class = "Healer", species = "Elf", heldItem = Nothing }]
  , reserve = []}


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
  | MovePartyMemberToReserve Characters.Character
  | MoveReserveMemberToParty Characters.Character
  | AddNewPartyMember Characters.Character
  | OpenItemAssigment Items.HeldItem
  | CloseItemAssignment
  | PerformItemAssignment Characters.Character Items.HeldItem
  | ReturnAssignedItem Characters.Character
  | BuyShopItem Items.ShopItem


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
      | party = List.filter (Characters.isNotSamePartyMember character) model.party
      , reserve = List.append model.reserve [character]}
    MoveReserveMemberToParty character ->
      if List.length model.party < maxPartySize
      then { model
      | reserve = List.filter (Characters.isNotSamePartyMember character) model.reserve
      , party = List.append model.party [character]}
      else model
    AddNewPartyMember character ->
      if List.length model.party >= maxPartySize
      then { model | reserve = List.append model.reserve [character] }
      else { model | party = List.append model.party [character] }
    OpenItemAssigment item ->
      { model | activeView = if item.numberAvailable > 0 then (ItemAssignmentViewOpen item) else Bag }
    CloseItemAssignment -> showBag model
    PerformItemAssignment character item ->
      if (character.heldItem == Nothing)
      then assignItem character item model |> showBag
      else (returnAssignedItem model character) |> (assignItem character item) |> showBag
    ReturnAssignedItem member -> returnAssignedItem model member
    BuyShopItem item -> { model | bag = Items.addItemToBag item.name model.bag, money = model.money - item.cost }





showBag: Model -> Model
showBag model = { model | activeView = Bag }

assignItem: Characters.Character -> Items.HeldItem -> Model -> Model
assignItem character item model =
  let newItem = { item | numberAvailable = item.numberAvailable - 1 } in
  { model
  | party = Characters.replacePartyMember { character | heldItem = Just newItem } { character | heldItem = Nothing } model.party
  , bag = Items.replaceBagItem newItem item model.bag}

returnAssignedItem: Model -> Characters.Character -> Model
returnAssignedItem model character =
  case character.heldItem of
    Nothing -> model
    Just item -> { model
            | party = Characters.replacePartyMember { character | heldItem = Nothing } character model.party
            , bag = Items.replaceBagItem { item | numberAvailable = item.numberAvailable + 1 } item model.bag}

moveToNewSpace: (Int, Int) -> Model -> Model
moveToNewSpace newPlayerCoordinates model = { model | playerCoordinates =
  if isForbiddenSpace model newPlayerCoordinates
  then model.playerCoordinates
  else newPlayerCoordinates }

isForbiddenSpace: Model -> (Int, Int) -> Bool
isForbiddenSpace model (newPlayerXPos, newPlayerYPos) =
  if newPlayerXPos >= model.currentMap.width
  || newPlayerYPos >= model.currentMap.height
  || newPlayerXPos < 0
  || newPlayerYPos < 0
  || List.member (newPlayerXPos, newPlayerYPos) model.currentMap.obstacles
  then True
  else False

handleMapInteractions: Model -> Model
handleMapInteractions model =
  if List.any (\(Map.Exit { coordinates }) -> coordinates == model.playerCoordinates) model.currentMap.exits
  then unlockNextDungeon  model |> advanceMap
  else if Just model.playerCoordinates == model.currentMap.shop
  then enterShop model
  else model

advanceMap: Model -> Model
advanceMap model =
  let (Map.Exit { nextMap, exitOpen, isDungeonExit }) = Map.findExitByCoordinates model.playerCoordinates model.currentMap.exits in
  let nextMapWithDefault = nextMap |> Maybe.withDefault (Map.hubMap model.dungeon1Complete model.dungeon2Complete model.dungeon3Complete) in
  if exitOpen then { model
                   | currentMap = nextMapWithDefault
                   , playerCoordinates = nextMapWithDefault.entrance }
  else model

unlockNextDungeon: Model -> Model
unlockNextDungeon model =
  let (Map.Exit { exitOpen, isDungeonExit }) = Map.findExitByCoordinates model.playerCoordinates model.currentMap.exits in
  if (not exitOpen || not isDungeonExit) then model
  else if not model.dungeon1Complete then { model | dungeon1Complete = True }
  else if not model.dungeon2Complete then { model | dungeon2Complete = True }
  else if not model.dungeon3Complete then { model | dungeon3Complete = True }
  else model

mockShopItems: List Items.ShopItem
mockShopItems =
  [ { name = "Wooden Shield", description = "Take 20% less damage, but take 2x fire damage", cost = 10 }
  , { name = "Channeling Staff", description = "Your magic attacks take an extra turn to charge, but deal 3x damage", cost = 100 }]
enterShop model = { model | activeView = Shop mockShopItems }

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
  (case model.activeView of
    Map -> [drawMapAndControls model]
    MainMenu -> [drawMenu model]
    Bag -> [drawBag model]
    Party -> [drawParty model]
    Reserve -> [drawReserve model]
    ItemAssignmentViewOpen item -> [drawItemAssignment item model]
    Shop shopItems -> [drawShop shopItems model]
    Battle enemies -> [drawBattleScene enemies model])

drawMapAndControls: Model -> Html Msg
drawMapAndControls model =
  div []
    [ div
      [ style "display" "flex"
      , style "flex-direction" "column"
      ] (List.map (drawMapRow model) (List.range 0 (model.currentMap.height - 1)))
    , div
      [ style "margin" "10px 0"
      , style "display" "flex"
      , style "justify-content" "space-around" ]
      [ button [ onClick MovePlayerLeft ] [ text "Left" ]
      , button [ onClick MovePlayerUp ] [ text "Up" ]
      , button [ onClick MovePlayerDown ] [ text "Down" ]
      , button [ onClick MovePlayerRight ] [ text "Right" ]]
    , button [ onClick OpenMenu ] [ text "Open Menu" ]]

drawMapRow: Model -> Int -> Html Msg
drawMapRow model yCoordinate =
  div[style "display" "flex"](List.map (drawMapSquare model yCoordinate) (List.range 0 (model.currentMap.width - 1)))

drawMapSquare: Model -> Int -> Int -> Html Msg
drawMapSquare model yCoordinate xCoordinate =
  div
    [ style "border" "solid black 1px"
    , style "padding" "5px"
    , style "width" "40px"
    , style "height" "40px"
    ]
    [ let squareCoordinates = (xCoordinate, yCoordinate) in
        if squareCoordinates == model.playerCoordinates then text "P"
        else if Just squareCoordinates == (model.currentMap.shop) then text "S"
        else if Just squareCoordinates == (model.currentMap.tavern) then text "T"
        else if List.any (\(Map.Exit { coordinates }) -> coordinates == squareCoordinates) model.currentMap.exits
          then let (Map.Exit { exitOpen }) = (Map.findExitByCoordinates squareCoordinates model.currentMap.exits) in
            if exitOpen then text "O" else text "X"
        else if List.member squareCoordinates model.currentMap.obstacles then text "*"
        else text " "]

drawShop: List Items.ShopItem -> Model -> Html Msg
drawShop shopItems model =
  div
    [ style "border" "solid black 1px"
    , style "margin" "10px"
    , style "padding" "10px"]
    [ div
      [ style "display" "flex"
      , style "justify-content" "space-between"
      , style "align-items" "center"]
      [ h3 [] [ text "Shop" ]
      , p [] [ text ("$" ++ String.fromInt model.money) ]]
      , hr [] []
      , div [] [ text "Shop Items" ]
      , hr [] []
      , div [] (List.map (drawShopItem model) shopItems)
      , button [ onClick LeaveShop ] [ text "Leave Shop" ]]

drawShopItem: Model -> Items.ShopItem -> Html Msg
drawShopItem model item =
  div []
    [ div
      [ style "display" "flex"
      , style "flex-direction" "row"
      , style "justify-content" "space-between"
      , style "align-items" "center"]
      [ h4 [] [ text item.name ]
      , p [] [ text ("$" ++ String.fromInt item.cost) ]]
    , p [] [ text item.description ]
    , button
      [ onClick (BuyShopItem item)
      , disabled (model.money < item.cost) ] [ text "Buy" ]]

drawMenu: Model -> Html Msg
drawMenu model =
  div
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
    , div [ style "padding" "5px 10px" ] [ button [ onClick CloseMenu ] [ text "Close" ]]]

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

drawBagItem: Items.HeldItem -> Html Msg
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

drawItemAssignment: Items.HeldItem -> Model -> Html Msg
drawItemAssignment item model =
  div
    [ style "border" "solid black 1px"
    , style "margin" "5px"
    , style "flex-direction" "column"]
    [ div [ style "padding" "5px 10px" ] [text ("Assign " ++ item.name ++ " to:") ]
    , div
      [ style "display" "flex"
      , style "flex-direction" "column"] (List.map (drawItemAssignmentPartyMember item) model.party)
      , button [ onClick CloseItemAssignment, style "margin" "5px 10px" ] [ text "Close" ]]

drawItemAssignmentPartyMember: Items.HeldItem -> Characters.Character -> Html Msg
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

drawPartyMember: Characters.Character -> Html Msg
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

drawPartyMemberHeldItem: Maybe Items.HeldItem -> Html Msg
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

drawReserveMember: Characters.Character -> Html Msg
drawReserveMember reserveMember =
  div
    [ style "padding" "5px 10px"]
    [ hr [ style "width" "85%", style "color" "lightgray" ] []
    , div [ style "font-weight" "bold" ] [text (reserveMember.species ++ " " ++ reserveMember.class) ]
    , drawReserveMemberHeldItem reserveMember.heldItem
    , div [] [ button [ onClick (MoveReserveMemberToParty reserveMember) ] [ text "Move to Party" ] ]]

drawReserveMemberHeldItem: Maybe Items.HeldItem -> Html Msg
drawReserveMemberHeldItem bagItem =
  case bagItem of
    Nothing -> div [ style "display" "none" ] []
    Just item -> div [] [text ("holding: " ++ item.name)]

drawBattleScene: List Battle.Enemy -> Model -> Html Msg
drawBattleScene enemies model =
  div [] []
