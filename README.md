# Rogue Like


## BUGS

- [ ] When you load a game the menu points in the inventory are stacked and not deserialized properly
- [ ] Level generation: When Boss room is spawned early, no more rooms are being added:
	- [ ] Add more entrances for boss room
	- [ ] Make algorythm understand that there is a deadend (Place bossroom as last room)
- [x] Camera is not perfectly ceneted on the start of skill tree and map
- [x] Dungeon generation issue (Sometimes wrong entrances get generated, mostly top entrances)
- [x] Animation index out of bounds when roll on exact same frame again -> new state is not processed because old state is also roll

## TODO

- [ ] Name
- [ ] Show Mana cost and cooldown of skills in description and when selecting spells
- [ ] Show skill name / description in Inventory
- [ ] Add Zoom to camera in map and skill tree
- [ ] Fix pathfinding collision with multiple enemies (increase attack range)
- [ ] Add torches in corridors
- [ ] Redo inventory
- [ ] Border around inventory
- [ ] Redo torch animation
- [ ] Close inventory button

- [ ] Implement perks in Player / Skill Tree
- [ ] Perks:
	- Moneygraber (get x% more money)
	
- [ ] Abilities (buyable with XP)
	- [ ] Fire:
		- [x] Primary: Fireball
		- [ ] Abilities:
			- [ ] Fire wave around player
			- [ ] 
			- [ ] Burning floor wave (aoe)
		- [ ] Perks:
			- [ ] Fire roll, burn floor on ground
	- [ ] Water:
		- [x] Primary: Water wave
		- [ ] Abilities:
			- [ ] Teleport
			- [ ] Counter
			- [ ] 
		- [ ] Perks:
			pass
	- [ ] Earth:
		- [x] Primary: Rock throw
		- [ ] Abilities:
			- [ ] Buff circle
			- [ ] Earth spike
			- [ ] Rock Roll
		- [ ] Perks:
			- [ ] 
- [ ] 3 Soundtracks:
	- [ ] Boss
		- [ ] Track
		- [ ] Integrated
	- [ ] Regular Fight
		- [x] Track
		- [ ] Integrated
	- [ ] Relaxed
		- [ ] Track
		- [ ] Integrated
- [ ] Lighting Overhaul / Design
- [ ] Decorations
	- [ ] Crates
	- [x] Torch
	? [ ] Lanterns
	- [ ] Chest
	- [ ] Pots
	- [ ] Table
	- [ ] Barrels
	- [ ] Spike (with Damage)
	- [ ] Explosing Barrels
- [ ] Sounds
	- [ ] Coin Collect
	- [x] Ui Button Click
	- [ ] Attack sounds(fireball, water wave, rock)
	- [x] Player Damage hit
	- [ ] Player heal potion
	- [ ] Enemy throw attack sound
	- [ ] Enemy Damage hit
	- [ ] Player roll
	- [ ] Level Up
	- [ ] Buy confirm
	- [ ] Player walk
- [ ] Enemies
	? [ ] Damage Number
	- [X] Path Finding
	- [ ] 4 enemy types (3 / 4)
		- [x] Thrower
		- [x] Axe Thrower
		- [x] Slime
		- ...
	- [ ] Boss: Goblin King (Ogre)
		- [ ] One Eye
		- [ ] blue color
- [ ] Rooms
	- [ ] 8 bad rooms (0 / 8)
	- [ ] 2 good rooms (0 / 2)
		- [ ] Shop
	- [ ] 2 neutral (0 / 2)
		- Gambling
	- [ ] 1 boss room
- [x] Redo tiles
- [x] Logo (temporary)
- [x] Custom cursor
- [x] Reset camera when opening skill tree or map
- [x] Enemy helathbar and damage numbers
- [x] Slime variations
- [x] Fix pathfinding with multiple enemies (good enough for now)
- [x] Roll through enemies
- [x] Player UI Remake
- [x] Adjust POV
- [x] Show difference between primary attacks and abilities
- [x] Silver, Gold and Bronze Coins (so far only gold)
- [x] Roll cooldown with Mana
- [x] Game Over screen
- [x] Shortcut for map, inventory and character
- [x] Reset camera in map and skilltree
- [x] Roll particle effect
- [x] Fix Zoom
- [x] Cool down UI
- [x] Stats and Upgrade stats on level up
- [x] Minimap Teleporting
- [x] Make room locked when entering
- [x] Dungeon Generation
- [x] Doors
- [x] Postprocessing with Glow
? [ ] Optimize room occluding
? [ ] Coin Collect animation
? [ ] Game Over screen transition
? [ ] Knockback projectiles
? [ ] Splash screen
? [ ] Enemy Spawn animation
? [ ] Room complete indicator (Make a rewarding effect when clearing a room)
? [ ] UI Theme
? [ ] Make second cursor for UI
? [ ] Level Up effect
? [ ] Rework enemy hitboxes (Make 2 hitboxes)
? [ ] Attributes:
	- [ ] Health: increases max health
	? [ ] Wisdom: increases max mana and mana regeneration
	? [ ] Endurance: increases max stamina and stamina regeneration
	- [ ] Power: Increases Attack Power
	- [ ] Agility: Increases movementspeed and roll
	? [ ] Luck: Increase drop chances


## PLANNED
- [ ] Boss entrance (ogre smahes through walls, hatching from egg, etc.)
- [ ] Mini Map
- [ ] Items (Amulets, rings, armor, staff, etc.)
- [ ] Other classes (warrior, bard, assasin, etc.):
	- [ ] Warrior
		- [ ] Faster roll
		- [ ] Short range projectiles
- [ ] Other Dungeons
	- [ ] ...
- [ ] Coop
- [ ] Roll preview (see where player is rolling when holding space)
- [ ] Add different consumables (potion options, food, etc.)
- [ ] Spacial Audio
- [ ] Controller support
- [ ] Status effects (frozen, crippled, time freeze)
- [ ] Chest with Item loot
- [ ] Add Input hinting
- [ ] Improve Camera with Limits, so yuo can see more during a fight
