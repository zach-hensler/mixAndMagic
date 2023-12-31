# Features
## MVP Features
### Characters
- implement character stats (with class & species influence)
- rng character generation
- allow multiple members of the same class & type
  - (currently buggy w/ moving members to/from reserve)
  - could give all members a uuid to differentiate
- add ability to remove party members?

### Shop
- create selling functionality
- create consumable items
- add consumable item functionality

### Map
- replace map letters with icons
- give each exit a custom letter/icon
- keep map centered around character (adjust drawing for loop to go from -x character pos to +x character pos)
- implement procedurally generated dungeon floors
- add campfires (or some place to heal characters mid-dungeon)
- add taverns for the hub for users to recruit new members
- add enemies to map, they should trigger battle view
- replace player on map with party members walking in a line (think pokemon mystery dungeon)

### ETC
- find a better way to check for item/player equality than deep comparison
- add keyboard event listener for movement
- add click events for mobile movement/selection
- save data in local storage

### Battle Mechanics
- add battle scene
- add experience
- add levels
- add level caps
- add attacks
- add stats
- add status effects
- add type mechanics
- add held items functionality

### Design
- Mobile Friendly

---
## Post MVP Features
- webgl graphics
- sprites
- player directionality (ex: I walk to the left, my character is now looking to the left)
- animations
- transferring save data across devices (via QR code?)
- difficulty selector
- more character classes/types
