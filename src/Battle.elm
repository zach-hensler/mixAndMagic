module Battle exposing (..)

import Items

type alias Enemy =
  { class: String
  , species: String
  , heldItem: Maybe Items.HeldItem
  , statusEffects: List String
  , damageTaken: Int}
