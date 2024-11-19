# Rogue Like

## Optimization

- [ ] ?Only show & update rooms when visible on screen

## BUGS

- [x] ?Camera does not center correctly when starting a game becuase of the popup
- [ ] Fix greyed out skill tree nodes after deserialization
- [x] Fix shifted names of enemies before entering rooms (711408093)
- [ ] ?Color map preview in different Colors
- [x] Fix reference in room children -> crash after deserialization
- [x] Room enter detection
- [x] Not all rooms are being used -> 3721335509
- [x] When you load a game the menu points in the inventory are stacked and not deserialized properly
- [x] Fix multihit with ice wave
- [x] Fix standing in spikes
- [x] Teleport through walls & objects
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
- [ ] Story (Endboss drops scroll)
- [ ] Warning before endboss
- [x] Focus camera on player in minimap
- [x] Show first room on minimap
- [ ] ?Make game fullscreeen by default
- [x] Tutorial (maybe add tutorial text in starting room)
- [x] Limit camera zoom 
- [x] Balance:
	- [X] Remove start tokens
	- [X] Enemy:
		- [x] xp 
		- [X] coins (slimes only drop copper)
		- [x] speed
		- [x] attack damage
		- [x] range
	- [X] Abilities:
		- [X] cost
		- [X] cooldowns
		- [X] description
		- [X] Primary attack should not use mana
- [x] Enemies
	- [x] Damage Number
	- [x] Healthbar
	- [X] Path Finding
	- [x] 3 enemy types (3 / 3)
		- [x] Spear Thrower
		- [x] Axe Thrower
		- [x] Slime (Red, Green, Blue)
		- [ ] ?Rat
	- [x] Boss: Goblin King (Ogre, Dragon, Dark Mage)
		- [x] 4 Attacks
- [x] Rooms
	- [x] 8 bad rooms (8 / 8)
	- [x] 2 good rooms (0 / 2)
		- [x] Free money room
		- [x] Shop (Buy potions, level points and skill points)
	- [x] 2 neutral (0 / 2)
		- [x] Empty room (with props)
		- [ ] ?Gambling
	- [x] 1 boss room
- [ ] ?Transition songs
- [ ] ?Check before using mana for ability
- [ ] ?Coin Magnet
- [x] Starting spell selection (only open start room after spell is bought)
- [x] Remove rooms in generation after used once
- [x] Abilities (buyable with XP)
	- [x] Fire:
		- [x] Primary: Fireball
		- [x] Abilities:
			- [ ] ?Fire beam many small little fire projectiles
			- [x] Fire wave around player
			- [x] Fire circle around player
			- [x] Heat buff (speed and damage)
			- [ ] ?Burning floor wave (aoe)
		- [ ] ?Perks:
			- [ ] ?Fire does more damage
			- [ ] ?Fire roll, burn floor on ground
		- [ ] ?Effects:
			- [ ] ?Burn
	- [x] Ice:
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
	- [x] Earth:
		- [x] Primary: Rock throw
		- [ ] Abilities:
			- [x] Buff circle or rock wall
			- [x] Earth spike
			- [x] Rock Roll
		- [ ] ?Perks:
			- [ ] ?More physical damage
			- [ ] ?Crippled enemies take more damage
			- [ ] ?Rolling deals damage
		- [ ] ?Effects:
			- [ ] ?Crippled
- [x] 3 Soundtracks:
	- [ ] ?Boss
		- [ ] ?Track
		- [ ] ?Integrated
	- [x] Regular Fight
		- [x] Track
		- [x] Integrated
	- [x] Relaxed
		- [x] Track
		- [x] Integrated
- [x] Sounds
	- [x] Coin Collect
	- [x] Ui Button Click
	- [ ] Attack sounds(fireball, water wave, rock)
	- [x] Player heal potion
	- [x] Error buy sound
	- [x] Enemy throw attack sound
  		- [x] Integrate
	- [x] Buy confirm
	- [x] Player step
  		- [x] Integrate
	- [x] Player Damage hit
		- [x] Integrate
  	- [x] Boss Damage hit
  		- [x] Integrate  
	- [x] Parry
	- [x] level up
	- [x] Enemy Damage hit (hitmarker)
	- [x] Player roll
 		- [x] Integrate

- [x] Decorations
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
- [ ] ?Show description on hover in hud
- [ ] ?Enemy walk and shoot animation
- [ ] ?Enemy avoidance
- [ ] ?Perks:
	- [ ] ?Moneygraber (get x% more money)
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
- [x] Add shop hint
- [x] Show nearby not visited rooms greyed out
- [x] Remove ui_effects
- [x] Show attack / ability tip
- [x] Create reusable sign or letter for everything, when player near -> text pop up
- [x] Spawn boss room on edge of dungeon (furthest away edge)
- [x] Show Mana cost, damage and cooldown of skills in description and when selecting spells
- [x] Show skill name / description in Inventory
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
- [x] Pop up on first level up (tutorial)
- [x] Name (Arcane Scrolls)
	- [x] Integrated
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
