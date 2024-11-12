# Rogue Like

## Optimization

- [ ] ?Only show & update rooms when visible on screen

## BUGS

- [x] Teleport through walls & objects
- [ ] ?Camera does not center correctly when starting a game becuase of the popup
- [x] When you load a game the menu points in the inventory are stacked and not deserialized properly
- [ ] Fix greyed out skill tree nodes after deserialization
- [x] Fix multihit with ice wave
- [x] Fix standing in spikes
- [x] Center camera does not center correctly
- [x] Fix pathfinding with tables
- [x] Level generation: When Boss room is spawned early, no more rooms are being added:
	- [x] Add more entrances for boss room
	- [x] Make algorythm understand that there is a deadend (Place bossroom as last room furthest left, right, bottm or top)
	- [x] Bugged Seeds: 2257926617, 550167171, 625328491, 475520497
- [x] Out of bounds glitch (probably when boss room cannot generate)
- [x] The same spell can be equiped multiple times
- [x] Camera is not perfectly ceneted on the start of skill tree and map
- [x] Dungeon generation issue (Sometimes wrong entrances get generated, mostly top entrances)
- [x] Animation index out of bounds when roll on exact same frame again -> new state is not processed because old state is also roll

## TODO

- [x] Name (Arcane Descent)
- [ ] Tutorial (maybe add tutorial text in starting room)
- [ ] ?Show description on hover in hud
- [x] Show nearby not visited rooms greyed out
- [x] Remove ui_effects
- [x] Show attack / ability tip
- [x] Create reusable sign or letter for everything, when player near -> text pop up
- [x] Spawn boss room on edge of dungeon (furthest away edge)
- [x] Show Mana cost, damage and cooldown of skills in description and when selecting spells
- [x] Show skill name / description in Inventory
- [ ] Balance:
	- [ ] Enemy xp reward, coins, speed, attack, and range
	- [ ] Ability cost, cooldowns and description -> Primary should be free and abailitites should use mana
	- [ ] Primary attack should not use mana
- [ ] Abilities (buyable with XP)
	- [ ] Fire:
		- [x] Primary: Fireball
		- [ ] Abilities:
			- [ ] ?Fire beam many small little fire projectiles
			- [x] Fire wave around player
			- [x] Fire circle around player
			- [ ] Heat buff (speed and damage)
			- [ ] ?Burning floor wave (aoe)
		- [ ] ?Perks:
			- [ ] ?Fire does more damage
			- [ ] ?Fire roll, burn floor on ground
		- [ ] ?Effects:
			- [ ] ?Burn
	- [ ] Ice:
		- [x] 1st Primary: Ice spear
		- [ ] Abilities:
			- [x] Teleport
			- [x] Counter
			- [x] Ice wave
			- ?[ ] Time slow
		- [ ] ?Perks:
			- [ ] ?Frost does more damage
			- [ ] ?Frozen enemies take more damage
			- [ ] ?Extra damage against frozen enemies
		- [ ] ?Effects:
			- [ ] ?Freeze
			- [ ] ?Bleed
			- [ ] ?Time slow
	- [ ] Earth:
		- [x] Primary: Rock throw
		- [ ] Abilities:
			- [ ] Buff circle or rock wall
			- [ ] Earth spike
			- [ ] Rock Roll
		- [ ] ?Perks:
			- [ ] ?More physical damage
			- [ ] Crippled enemies take more damage
			- [ ] ?Rolling deals damage
		- [ ] ?Effects:
			- [ ] ?Crippled
- [ ] 3 Soundtracks:
	- [ ] ?Boss
		- [ ] ?Track
		- [ ] ?Integrated
	- [ ] Regular Fight
		- [x] Track
		- [ ] Integrated
	- [ ] Relaxed
		- [x] Track
		- [ ] Integrated
- [ ] Decorations
	- [x] Torch
	- [x] Table
	- [x] Barrels
	- [x] Spike (with Damage)
	- [x] Crate
	- [ ] ?Boulder
	- [ ] ?Pots
	- [ ] ?Make decorations destroyable
	- [ ] ?Explosing Barrels
	- [ ] ?Lanterns
	- [ ] ?Chest
- [ ] Sounds
	- [x] Coin Collect
	- [x] Ui Button Click
	- [ ] Attack sounds(fireball, water wave, rock)
	- [ ] (Andri) Player heal potion
	- [ ] Error buy sound
	- [x] Enemy throw attack sound
  		- [ ] Integrate
	- [ ] (Andri) Buy confirm
	- [x] Player step
  		- [ ] Integrate
	- [x] Player Damage hit
		- [ ] Integrate
  	- [x] Boss Damage hit
  		- [ ] Integrate  
	- [x] Parry
	- [x] level up
	- [x] Enemy Damage hit (hitmarker)
	- [x] Player roll
 		- [ ] Integrate 	
- [ ] Enemies
	- [x] Damage Number
	- [x] Healthbar
	- [X] Path Finding
	- [x] 3 enemy types (3 / 3)
		- [x] Spear Thrower
		- [x] Axe Thrower
		- [x] Slime (Red, Green, Blue)
		- [ ] ?Rat
	- [ ] Boss: Goblin King (Ogre, Dragon, Dark Mage)
		- [ ] 4 Attacks
- [ ] Rooms
	- [ ] 8 bad rooms (0 / 8)
	- [ ] 2 good rooms (0 / 2)
		- [ ] Free potion room
		- [ ] Shop (Buy potions, level points and skill points)
	- [ ] 2 neutral (0 / 2)
		- [ ] Empty room (with props)
		- [ ] ?Gambling
	- [x] 1 boss room

- [x] Attributes:
	- [x] Health: increases max health
	- [x] Power: Increases Attack Power
	- [x] Agility: Increases movementspeed (?and roll)
	- [ ] ?Luck: Increase drop chances
	- [ ] ?Wisdom: increases max mana and mana regeneration
	- [ ] ?Endurance: increases max stamina and stamina regeneration

- [ ] ?Lighting Overhaul / Design
- [ ] ?Redo torch animation
- [ ] ?Implement perks in Player / Skill Tree
- [ ] ?Perks:
	- Moneygraber (get x% more money)
- [ ] ?Optimize room occluding
- [ ] ?Coin Collect animation
- [ ] ?Add Zoom to camera in map and skill tree
- [ ] ?Game Over screen transition
- [ ] ?Knockback projectiles
- [ ] ?Splash screen
- [ ] ?Enemy Spawn animation
- [ ] ?Room complete indicator (Make a rewarding effect when clearing a room)
- [ ] ?UI Theme
- [ ] ?Make second cursor for UI
- [ ] ?Rework enemy hitboxes (Make 2 hitboxes)
- [x] Redo skill / upgrade token icons
- [x] Add Level Up Text
- [x] Apply random offset to damage number
- [x] Make seed input field
- [x] Remove projectiles on room enter
- [x] Add torches in corridors
- [x] Level Up effect
- [x] Redo inventory
- [x] Border around inventory
- [x] Close inventory button
- [x] Spacial Audio
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

## PLANNED

- [ ] Refactor methods with get / set
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
- [ ] Restart soundtrack when tabing into game
- [ ] Roll preview (see where player is rolling when holding space)
- [ ] Add different consumables (potion options, food, etc.)
- [ ] Controller support
- [ ] Status effects (frozen, crippled, time freeze)
- [ ] Chest with Item loot
- [ ] Add Input hinting
- [ ] ghosting effect on health
- [ ] Improve Camera with Limits, so yuo can see more during a fight
