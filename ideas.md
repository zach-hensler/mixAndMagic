# Design Ideas for Mix and Magic (working title)

## Core Principles:
- RPG 3v3 turn based battles
- Player can combine items and teams to create powerful feeling builds
- Partners are inherently weak and items are inherently powerful
- Player is given a choice from limited options to encourage experimentation and reward when a build comes together
- Level caps + high exp yield prevents grinding from being a core mechanic
- Partners have different classes and types, each granting unique strengths and weaknesses

## Implementation Ideas:
- Max Party size of 3, can store some reserves
- Perma-death?  If offered as an option, it should be designed around.  Personally, I don't like this.
- Player enters "zones"
- Each Zone starts by offering a choice between 2 (3?) new partners
- Possibly battle the other partners after making their selection?
- Each Zone has a shop that the player can buy held and consumable items in exchange for coin
- Each Zone has (optional) battles to earn coin and exp
- Opponents will have a random team from a preset pool of options.
- Each Zone has a "Zone Boss" that must be cleared in order to progress
- Zone Boss could "cheat" somehow (ex: 4 partners instead of 3, above level cap)
- Clearing a Zone Boss increases your level cap
- You get offered a "global upgrade" after beating the Zone Boss
- max 2 global upgrades, any more after that must replace an old one
- ex: take less damage, deal more damage, lifesteal does double healing
- Players cannot return to a Zone after leaving
- After X Zones, the player has to face some sort of "final challenge"

Technical Details:
Elm language in a web browser

    example state = {
        playerLocation: {
            map: string,
            x: number,
            y: number
        },
        party: [
            {
                species: string,
                nickname: string,
                heldItem: string,
                healthRemaining: number
                statusCondition: string
            }
        ],
        bag: {
            heldItems: {
                xyz: {
                    hasBeenFound: boolean
                    isInUse: boolean
                }
            },
            consumableItems: {
                xyz: number
            }
        }
    }

    held items:
        draining amulet - attacks heal the user for a percentage of health
        wooden shield - increases defense, but takes additional fire damage
        channeling staff - magic attacks take an extra turn to charge, but deal more damage
        cursed gloves - melee attacks inflict a curse dealing damage over time
    consumable items:
        red elixir - heals damage
        blue elixir - increases attack for this zone
        green elixir - increases defense for this zone

    statuses:
        curse (dark) - deals damage over time, stacks
        blessed (light) - takes less damage and/or heals every turn


    classes:
        healer:
            support
            self-healing
            healing teammates
            de-buffs
            medium bulk
            low attack power
        tank:
            high bulk
            medium attack power
            crowd control
            some support
        fighter (elemental types):
            high attack power
            medium bulk
            reckless
            straightforward
        mage:
            low bulk
            high attack power
            strategic
            devious
            additional effects on attacks
    types:
        light:
        dark:
        water:
        wind:
        earth:
        fire: