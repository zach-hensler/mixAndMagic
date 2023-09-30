module Map exposing (..)


------------------------
-- Types ---------------
------------------------

type alias Coordinates = (Int, Int)
type Exit = Exit
  { coordinates: Coordinates
  , nextMap: (Maybe Map)
  , exitOpen: Bool
  , isDungeonExit: Bool}

type alias Map =
  { height: Int
  , width: Int
  , entrance: Coordinates
  , shop: Maybe Coordinates
  , campfire: Maybe Coordinates
  , obstacles: List Coordinates
  , exits: List Exit}


------------------------
-- Hub -----------------
------------------------

hubMap: Bool -> Bool -> Bool -> Map
hubMap dungeon1Complete dungeon2Complete dungeon3Complete =
  { height = 10
  , width = 7
  , entrance = (3, 9)
  , shop = Just (0, 6)
  , campfire = Nothing
  , obstacles = []
  , exits =
    [ Exit
      { coordinates = (0, 2)
      , nextMap = (Just dungeon1Floor1)
      , exitOpen = True
      , isDungeonExit = False}
    , Exit
      { coordinates = (3, 0)
      , nextMap = (Just dungeon2Floor1)
      , exitOpen = dungeon1Complete
      , isDungeonExit = False}
    , Exit
      { coordinates = (6, 2)
      , nextMap = (Just dungeon3Floor1)
      , exitOpen = dungeon2Complete
      , isDungeonExit = False}]}


------------------------
-- Dungeon 1 -----------
------------------------

dungeon1Floor1: Map
dungeon1Floor1 =
  { height = 5
  , width = 10
  , entrance = (1, 1)
  , shop = Nothing
  , campfire = Nothing
  , obstacles = []
  , exits =
    [ Exit
      { coordinates = (9, 4)
      , nextMap = (Just dungeon1Floor2)
      , exitOpen = True
      , isDungeonExit = False}]}

dungeon1Floor2: Map
dungeon1Floor2 =
  { height = 1
  , width = 7
  , entrance = (0, 0)
  , shop = Nothing
  , campfire = Nothing
  , obstacles = []
  , exits =
    [ Exit
      { coordinates = (6, 0)
      , nextMap = Nothing
      , exitOpen = True
      , isDungeonExit = True}]}


------------------------
-- Dungeon 2 -----------
------------------------

dungeon2Floor1: Map
dungeon2Floor1 =
  { height = 10
  , width = 5
  , entrance = (1, 1)
  , shop = Nothing
  , campfire = Nothing
  , obstacles = []
  , exits =
    [ Exit
      { coordinates = (4, 9)
      , nextMap = (Just dungeon2Floor2)
      , exitOpen = True
      , isDungeonExit = False}]}

dungeon2Floor2: Map
dungeon2Floor2 =
  { height = 12
  , width = 2
  , entrance = (0, 0)
  , shop = Nothing
  , campfire = Nothing
  , obstacles = []
  , exits =
    [ Exit
      { coordinates = (1, 11)
      , nextMap = Nothing
      , exitOpen = True
      , isDungeonExit = True}]}


------------------------
-- Dungeon 3 -----------
------------------------

dungeon3Floor1: Map
dungeon3Floor1 =
  { height = 10
  , width = 10
  , entrance = (1, 1)
  , shop = Nothing
  , campfire = Nothing
  , obstacles = []
  , exits =
    [ Exit
      { coordinates = (9, 9)
      , nextMap = Nothing
      , exitOpen = True
      , isDungeonExit = True}]}


------------------------
-- Helper Functions ----
------------------------

findExitByCoordinates: Coordinates -> List Exit -> Exit
findExitByCoordinates searchCoordinates exitList = List.head (List.filter (\(Exit { coordinates }) -> coordinates == searchCoordinates) exitList)
                    |> Maybe.withDefault (Exit { coordinates = (9, 4), nextMap = Nothing, exitOpen = True, isDungeonExit = False})