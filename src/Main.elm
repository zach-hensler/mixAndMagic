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
type alias BagItem = { name: String, description: String, numberAvailable: Int, numberOwned: Int }
type alias PartyMember = { class: String, elementalType: String, heldItem: String }

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
  , shopViewOpen: Bool
  , menuViewOpen: Bool
  , partyViewOpen: Bool
  , reserveViewOpen: Bool
  , bagViewOpen: Bool
  , bag: List BagItem
  , party: List PartyMember
  , reserveParty: List PartyMember}

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
  , shopViewOpen = False
  , menuViewOpen = False
  , partyViewOpen = False
  , reserveViewOpen = False
  , bagViewOpen = False
  , bag =
    [ { name = "Life Orb", description = "Deals more damage, but takes recoil", numberAvailable = 0, numberOwned = 1 }
    , { name = "Leftovers", description = "Heals a little bit every turn", numberAvailable = 0, numberOwned = 1 }]
  , party =
    [ { class = "Mage", elementalType = "Fire", heldItem = "Life Orb" }
    , { class = "Healer", elementalType = "Light", heldItem = "Leftovers" }]
  , reserveParty = []}

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
  | MovePartyMemberToReserve PartyMember
  | MoveReserveMemberToParty PartyMember
  | AddNewMember PartyMember
  --| GiveItemToMember PartyMember BagItem


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
    LeaveShop -> { model | shopViewOpen = False }
    OpenMenu -> { model | menuViewOpen = True }
    CloseMenu -> { model | menuViewOpen = False, bagViewOpen = False, partyViewOpen = False, reserveViewOpen = False }
    OpenParty -> { model | partyViewOpen = True }
    CloseParty -> { model | partyViewOpen = False }
    OpenReserve -> { model | reserveViewOpen = True }
    CloseReserve -> { model | reserveViewOpen = False }
    OpenBag -> { model | bagViewOpen = True }
    CloseBag -> { model | bagViewOpen = False }
    MovePartyMemberToReserve member ->
      { model
      | party = List.filter (isNotSamePartyMember member) model.party
      , reserveParty = List.append model.reserveParty [member]}
    MoveReserveMemberToParty member ->
      if List.length model.party < maxPartySize
      then { model
      | reserveParty = List.filter (isNotSamePartyMember member) model.reserveParty
      , party = List.append model.party [member]}
      else model
    AddNewMember member ->
      if List.length model.party >= maxPartySize
      then { model | reserveParty = List.append model.reserveParty [member] }
      else { model | party = List.append model.party [member] }
    --GiveItemToMember member item ->
    --  if (member.heldItem == "")
    --  then { model |  }
    --  else


isNotSamePartyMember: PartyMember -> PartyMember -> Bool
isNotSamePartyMember member1 member2 = not (member1 == member2)

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

enterShop model = { model | shopViewOpen = True }

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
    , div [ style "display" (if model.shopViewOpen then "block" else "none") ]
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
      , style "display" (if model.menuViewOpen then "none" else "block")] [ text "Open Menu" ]
    , div
      [ style "border" "solid black 1px"
      , style "margin" "5px"
      , style "display" (if model.menuViewOpen then "flex" else "none")
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
    , style "display" (if (model.bagViewOpen) then "flex" else "none" )
    , style "flex-direction" "column"]
  [ div [ style "padding" "5px 10px" ] [text "Bag"]
  , div
    [ style "display" "flex"
    , style "flex-direction" "column"] (List.map drawBagItem model.bag)
  , button [ onClick CloseBag, style "margin" "5px 10px" ] [ text "Close" ] ]

drawBagItem: BagItem -> Html Msg
drawBagItem bagItem =
  div
    [ style "padding" "5px 10px"]
    [ hr [ style "width" "85%", style "color" "lightgray" ] []
    , div [ style "font-weight" "bold" ] [text bagItem.name]
    , div
      [ style "display" "flex"]
      [ div [ style "width" "70%" ] [ text bagItem.description ]
      , div [ style "width" "30%" ] [ text (String.fromInt bagItem.numberAvailable ++ "/" ++ String.fromInt bagItem.numberOwned) ]]]

drawParty: Model -> Html Msg
drawParty model =
  div
    [ style "border" "solid black 1px"
    , style "margin" "5px"
    , style "display" (if (model.partyViewOpen) then "flex" else "none" )
    , style "flex-direction" "column"]
  [ div [ style "padding" "5px 10px" ] [text "Party"]
  , div
    [ style "display" "flex"
    , style "flex-direction" "column"] (List.map drawPartyMember model.party)
  , button [ onClick CloseParty, style "margin" "5px 10px" ] [ text "Close" ] ]

drawPartyMember: PartyMember -> Html Msg
drawPartyMember partyMember =
  div
    [ style "padding" "5px 10px"]
    [ hr [ style "width" "85%", style "color" "lightgray" ] []
    , div [ style "font-weight" "bold" ] [text (partyMember.elementalType ++ " " ++ partyMember.class) ]
    , div [ style "display" (if (String.isEmpty partyMember.heldItem) then "none" else "block") ] [text ("holding: " ++ partyMember.heldItem)]
    , div [] [ button [ onClick (MovePartyMemberToReserve partyMember) ] [ text "Move to Reserve" ] ]]

drawReserve: Model -> Html Msg
drawReserve model =
  div
    [ style "border" "solid black 1px"
    , style "margin" "5px"
    , style "display" (if (model.reserveViewOpen) then "flex" else "none" )
    , style "flex-direction" "column"]
  [ div [ style "padding" "5px 10px" ] [text "Reserve"]
  , div
    [ style "display" "flex"
    , style "flex-direction" "column"] (List.map drawReserveMember model.reserveParty)
  , button [ onClick CloseReserve, style "margin" "5px 10px" ] [ text "Close" ] ]

drawAddNewMemberButton: Model -> Html Msg
drawAddNewMemberButton model =
  div []
    [ button
      [ onClick (AddNewMember
        { class = "Mage"-- Random.generate getRandomClass
        , elementalType = "Dark"-- Random.map getRandomClass
        , heldItem = "" } )]
      [ text "Add new member" ]]

--getRandomClass: Random.Generator String
--getRandomClass = Random.Pcg.sample
  --let randomNumber = Random.int 0 3 in
  --case randomNumber of
  --  0 -> "Cleric"
  --  1 -> "Mage"
  --  2 -> "Fighter"
  --  _ -> "Tank"

--getRandomType: String
--getRandomType =
--  let randomNumber = Random.int 0 4 in
--   case randomNumber of
--     0 -> "Fire"
--     1 -> "Water"
--     2 -> "Earth"
--     3 -> "Light"
--     _ -> "Dark"

drawReserveMember: PartyMember -> Html Msg
drawReserveMember reserveMember =
  div
    [ style "padding" "5px 10px"]
    [ hr [ style "width" "85%", style "color" "lightgray" ] []
    , div [ style "font-weight" "bold" ] [text (reserveMember.elementalType ++ " " ++ reserveMember.class) ]
    , div [ style "display" (if (String.isEmpty reserveMember.heldItem) then "none" else "block") ] [text ("holding: " ++ reserveMember.heldItem)]
    , div [] [ button [ onClick (MoveReserveMemberToParty reserveMember) ] [ text "Move to Party" ] ]]
