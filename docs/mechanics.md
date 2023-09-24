# Game Mechanics

## Core Principles:
- RPG 3v3 turn based battles
- Player can combine items and teams to create powerful feeling builds
- Characters are inherently weak and items are inherently powerful
- Player is given a choice from limited options to encourage experimentation and reward when a build comes together
- Level caps + high exp yield prevents grinding from being a core mechanic
- Characters have different classes and species, each granting unique strengths and weaknesses

## Implementation Ideas:
- Player starts in a hub area in this area there is:
  - A way for the player to recruit new characters
  - A way for the player to buy new items
  - Different dungeons that the player can enter
- Dungeons:
  - As a player enters a dungeon, they must select 3 characters (and their held items) to take with them
  - The player is forced to leave the dungeon after their party faints or they clear the final boss
  - They player must navigate through several floors of the dungeon, and fight enemies along the way
    - Dungeon enemies will have teams of 1-3 members
    - Dungeon enemies will reward the player with experience, money, and potential consumable item drops
    - At the end of the dungeon, the player has to face a boss.  Defeating the boss gives the player a treasure
      - Potential treasures include:
        - permanent global buffs (ex: members take less damage, deal more damage, +% chance of effects happening)
        - lots o cash
        - choice of held items
    - After clearing a dungeon, the level cap is increased
  - Players can re-enter dungeons for extra exp/money, but will not receive an extra "big reward"

## Items:
### Held Items
- draining amulet - attacks heal the user for a percentage of health
- wooden shield - increases defense, but takes additional fire damage
- channeling staff - magic attacks take an extra turn to charge, but deal more damage
- cursed gloves - melee attacks inflict a curse dealing damage over time

### Consumable Items
- red elixir - heals damage
- blue elixir - increases attack for this zone
- green elixir - increases defense for this zone

## Characters
- A character has:
  - A class
    - Randomly generated
  - A species
    - Randomly generated
  - Stats
    - Base stats + class modifiers + species modifiers + ability modifiers (if applicable)
  - Moves
    - species specific moves
    - class specific moves
    - species + class specific moves
  - Abilities?
    - Could come from species or class (undecided)
    - Randomly generated from a pre-determined list of options

### Stats:
- health
  - Determines how much damage the character can take before fainting
- defense
  - Determines how much damage the character will take from an attack
- speed
  - Determines move order during battle
- attack
  - Determines how much damage that character can deal

### Character Classes:
- Healer
  - stat changes: -attack +speed
  - support
  - self-healing
  - healing teammates
  - de-buffs
- Tank:
  - stat changes: +hp +defense --speed
  - crowd control
  - some support
- Fighter:
  - stat changes: +attack +hp -defense
  - reckless
  - straightforward
- Mage:
  - stat changes: +attack -hp -defense +speed
  - strategic
  - devious
  - additional effects on attacks

### Character Species:
- human
  - stat changes: none
- elf
  - stat changes: -hp, +attack, +speed
- cat
  - stat changes: -hp, -defense, ++speed
- wolf
  - stat changes: +speed, +defense, --hp, +attack
- giant
  - stat changes: --speed, ++hp, ++defense

## Statuses
- curse - deals damage over time, stacks
- blessed - takes less damage and/or heals every turn
