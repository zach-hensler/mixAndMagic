module Characters exposing (..)

import Items

type alias Character = { class: String, species: String, heldItem: Maybe Items.HeldItem }

replacePartyMember: Character -> Character -> List Character -> List Character
replacePartyMember newMember oldMember memberList =
  List.map (\m -> if m == oldMember then newMember else m) memberList

isNotSamePartyMember: Character -> Character -> Bool
isNotSamePartyMember character1 character2 = not (character1 == character2)
