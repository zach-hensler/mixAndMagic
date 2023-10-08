module Items exposing (..)


type alias ShopItem = { name: String, description: String, cost: Int }
type alias HeldItem = { name: String, description: String, numberAvailable: Int, numberOwned: Int }

addItemToBag: String -> List HeldItem -> List HeldItem
addItemToBag newItemName bag =
  let prevItem = findItemByName newItemName bag in
  case prevItem of
    Nothing -> bag
    Just item -> replaceBagItem
                  { item | numberOwned = item.numberOwned + 1, numberAvailable = item.numberAvailable + 1 }
                  item bag

findItemByName: String -> List HeldItem -> Maybe HeldItem
findItemByName itemName bag =
  List.head (List.filter (\i -> i.name == itemName) bag)

replaceBagItem: HeldItem -> HeldItem -> List HeldItem -> List HeldItem
replaceBagItem newItem oldItem itemList =
  List.map (\i -> if i == oldItem then newItem else i) itemList
