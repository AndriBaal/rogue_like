extends CharacterBody2D

class_name Player


enum PlayerAttackSlot {
	PRIMARY_ATTACK,
	ABILITY1,
	ABILITY2,
	ABILITY3
}

static func string_to_slot(string: String) -> PlayerAttackSlot:
	match string:
		'primary_attack':
			return PlayerAttackSlot.PRIMARY_ATTACK
		'ability1':
			return PlayerAttackSlot.ABILITY1
		'ability2':
			return PlayerAttackSlot.ABILITY2
		'ability3':
			return PlayerAttackSlot.ABILITY3
		_:
			push_error('Unknown string to slot')
			return PlayerAttackSlot.PRIMARY_ATTACK

static func slot_to_string(slot: PlayerAttackSlot) -> String:
	match slot:
		PlayerAttackSlot.PRIMARY_ATTACK:
			return 'primary_attack'
		PlayerAttackSlot.ABILITY1:
			return 'ability1'
		PlayerAttackSlot.ABILITY2:
			return 'ability2'
		PlayerAttackSlot.ABILITY3:
			return 'ability3'
		_:
			push_error('Unknown slot')
			return 'ERROR'

			
static func slot_to_type(slot: PlayerAttackSlot) -> AttackType:
	match slot:
		PlayerAttackSlot.PRIMARY_ATTACK:
			return AttackType.PRIMARY
		PlayerAttackSlot.ABILITY1, PlayerAttackSlot.ABILITY2, PlayerAttackSlot.ABILITY3:
			return AttackType.ABILITY
		_:
			push_error('Unknown slot')
			return AttackType.PRIMARY
			
enum AttackType {
	PRIMARY,
	ABILITY
}

static func type_to_string(type: AttackType) -> String:
	match type:
		AttackType.PRIMARY:
			return 'Primary'
		AttackType.ABILITY:
			return 'Secondary'
		_:
			push_error('Unknown type')
			return 'ERROR'

enum PlayerState {
	IDLE,
	IDLE_ATTACK,
	WALK,
	WALK_ATTACK,
	ROLL
}

@onready var game: Game = $/root/game
@onready var mana_bar := $ui/hud/mana_bar
@onready var inventory: Inventory = $ui/inventory

@export var xp_for_lvl_up := 50:
	get():
		return xp_for_lvl_up
	set(value):
		xp_for_lvl_up = value
		$ui/hud/xp/bar.max_value = value
@export var speed := 600.0
@export var immunity_duration := 1.5

@export var direction := Direction.SOUTH
@export var state: PlayerState = PlayerState.IDLE
@export var movement: Vector2
@export var animation_timer := 0.0
@export var immunity_timer := immunity_duration
@export var max_health := 28.0:
	get:
		return max_health
	set(value):
		max_health = value
		heal(0.0)
		#if value > max_health:
			#var diff = max_health
			#max_health = value
			#heal(diff)
		#else:
			#max_health = value
			#heal(0.0)
		
@export var health := max_health
@export var xp := 0:
	get:
		return xp
	set(value):
		xp = max(value, 0)
		var bar = $ui/hud/xp/bar
		while xp >= xp_for_lvl_up:
			xp -= xp_for_lvl_up
			level += 1
			_level_up()
		bar.max_value = float(xp_for_lvl_up)
		bar.value = float(xp)
@export var level := 0:
	get():
		return level
	set(value):
		level = value
		$ui/hud/xp/level.text = str(level)

@export var mana_per_second = 5.5
@export var max_mana := 50.0
@export var mana := max_mana
@export var attack_cooldowns := {
	PlayerAttackSlot.PRIMARY_ATTACK : 0.0,
	PlayerAttackSlot.ABILITY1 : 0.0,
	PlayerAttackSlot.ABILITY2 : 0.0,
	PlayerAttackSlot.ABILITY3 : 0.0,
}

@export var attacks := {}
@export var active_attacks := {
	PlayerAttackSlot.PRIMARY_ATTACK : null,
	PlayerAttackSlot.ABILITY1 : null,
	PlayerAttackSlot.ABILITY2 : null,
	PlayerAttackSlot.ABILITY3 : null,
}
@export var skill_tree := []

@export var max_potions := 10
@export var potions := 3

const DEFAULT_ROLL_SPEED := 0.5
@export var roll_cost = 5.0
@export var roll_duration := DEFAULT_ROLL_SPEED
@export var roll_speed := 750.0
@export var roll_timer := 0.0
@export var roll_immunity_range: Vector2 = Vector2(0.05, 0.95)

@export var parry_timer := 0.0
@export var parry_duration = 0.2

@export var money := 0:
	get():
		return money
	set(value):
		money = value
		$ui/hud/money/label.text = str(money)
@export var health_stat := 1
@export var attack_stat := 1
@export var speed_stat := 1
@export var init := false
@export var level_up_tokens := 0:
	get:
		return level_up_tokens
	set(val):
		level_up_tokens = val
		$ui/inventory/character/content.update_level_up_token_ui(val)
@export var skill_tokens := 1:
	get:
		return skill_tokens
	set(val):
		skill_tokens = val
		$ui/inventory/skill_tree/content.update_skill_token_ui(val)
@export var effects := {}
@export var step_timer = 0.0

const STEP_INTERVAL := 0.3
const GAME_OVER := preload("res://ui/game_over.tscn")

func _ready() -> void:
	$ui/inventory/skill_tree/content.init_tree(self.skill_tree, self.attacks)
	if not init:
		init = true
		self.game.spawn_pop_up(
			'How to play', 
			"Use 'W', 'A', 'S', and 'D' to move around. If you're new, be sure to read the letters on the ground. Check the center note to learn how to leave the first room."
		)
		self.game.spawn_pop_up(
			'We need your help!', 
			"The evil sorcerer Draziw has seized your sacred scroll, plunging the land into chaos. Brave the depths of his dark dungeon, where traps and minions await. Confront Draziw and reclaim the scroll to restore balance."
		)
		self._update_potion_ui()
		$ui/inventory/skill_tree/content.init_tree(self.skill_tree, self.attacks)
	
func _process(delta: float) -> void:
	for action in ["skill_tree", "character", "map"]:
		if Input.is_action_just_pressed(action):
			self.inventory.visible = !self.inventory.visible
			self.inventory.make_active(action)
	
	var new_movement := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	var new_state
	var new_direction := self.direction
	var movement_direction = Direction.from_vector(new_movement)
	var player_position := self.position
	var is_moving := new_movement != Vector2.ZERO
	var mouse_pos: Vector2 = self.game.get_local_mouse_position()
	var look: Vector2 = (mouse_pos - player_position).normalized()
	
	self.parry_timer += delta
	self.step_timer -= delta
	self.roll_timer -= delta
	
	var roll := Input.is_action_just_pressed("roll")
	var roll_begin = roll and self._has_enough_mana(self.roll_cost) and self.state != PlayerState.ROLL
	var still_rolling =  roll_timer >= 0.0 and self.state == PlayerState.ROLL
	if roll_begin or still_rolling:
		new_state = PlayerState.ROLL
	elif not is_moving:
		new_state = PlayerState.IDLE
	else:
		new_state = PlayerState.WALK
		new_direction = movement_direction

	self._update_mana(delta)
	if Input.is_action_just_pressed("heal"):
		self._use_potion()
	
	for attack_slot in self.attack_cooldowns:
		var attack = self.active_attacks[attack_slot]
		if attack:
			self.attack_cooldowns[attack_slot] -= delta
			var attack_ui = self.get_node('ui/hud/attack/' + slot_to_string(attack_slot))
			var occluder = attack_ui.get_node(^'occluder')
			var ratio = max(0.0, self.attack_cooldowns[attack_slot] / attack['cool_down'])
			occluder.scale.y = ratio
	
	var longest_effect = INF
	self.modulate = Color.WHITE
	for effect_name in self.effects.keys():
		var effect = self.effects[effect_name]
		effect['duration'] -= delta
		var duration = effect['duration']
		if 'color' in effect and duration < longest_effect:
			longest_effect = duration
			self.modulate = effect['color']
		if duration <= 0.0:
			self.effects.erase(effect_name)
		
			
	if not inventory.visible and new_state != PlayerState.ROLL:
		for attack_slot in self.active_attacks:
			if Input.is_action_pressed(slot_to_string(attack_slot)):
				var attack = self.active_attacks[attack_slot]
				if not attack:
					continue
				
				if 'condition' in attack and not self.call(attack['condition']):
					$buy_fail_audio.play()
					continue
				
				new_direction = Direction.from_vector(look)
				if not is_moving:
					new_state = PlayerState.IDLE_ATTACK
				else:
					new_state = PlayerState.WALK_ATTACK
						
				if self.attack_cooldowns[attack_slot] <= 0.0 and self._use_mana(attack['mana_cost']):
					self.attack_cooldowns[attack_slot] = attack['cool_down']
					var attack_result = self.call(attack['action'], player_position, look)
					
					if attack_result is PlayerState:
						new_state = attack_result

	if new_state != self.state:
		self.make_intangible(false)
		$walk_sprite.visible = false
		$idle_sprite.visible = false
		$idle_attack_sprite.visible = false
		$walk_attack_sprite.visible = false
		$roll_sprite.visible = false
		self.animation_timer = 0.0
		match new_state:
			PlayerState.ROLL:
				$roll_particle.restart()
				$roll_audio.play()
				self._use_mana(self.roll_cost)
				self.roll_timer = self.roll_duration
				$roll_sprite.visible = true
				self.movement = new_movement if is_moving else look
				self.direction = Direction.from_vector(self.movement)
			PlayerState.IDLE_ATTACK:
				$idle_attack_sprite.visible = true
			PlayerState.IDLE:
				$idle_sprite.visible = true
			PlayerState.WALK:
				$walk_sprite.visible = true
			PlayerState.WALK_ATTACK:
				$walk_attack_sprite.visible = true

	if new_state != PlayerState.ROLL:
		self.direction = new_direction
		self.movement = new_movement
	self.state = new_state
	
	var active_sprite
	match self.state:
		PlayerState.ROLL:
			active_sprite = $roll_sprite
			active_sprite.frame_coords.x = int(abs(self.roll_timer - self.roll_duration) / self.roll_duration * active_sprite.hframes)
			self.animation_timer += delta
			self.make_intangible(self.has_roll_iframes())
		PlayerState.IDLE:
			active_sprite = $idle_sprite
		PlayerState.IDLE_ATTACK:
			active_sprite = $idle_attack_sprite
		PlayerState.WALK:
			active_sprite = $walk_sprite
			active_sprite.frame_coords.x = int(self.animation_timer * 32.0) % active_sprite.hframes
			self.animation_timer += delta
		PlayerState.WALK_ATTACK:
			active_sprite = $walk_attack_sprite
			active_sprite.frame_coords.x = int(self.animation_timer * 32.0) % active_sprite.hframes
			self.animation_timer += delta
			
	if (self.state == PlayerState.WALK or self.state == PlayerState.WALK_ATTACK) \
		and self.step_timer <= 0.0 and not $step_audio.playing:
		$step_audio.play()
		self.step_timer = STEP_INTERVAL

	active_sprite.frame_coords.y = self.direction
	self._compute_immunity(delta, active_sprite)

func _input(_event: InputEvent) -> void:
	if not inventory.visible:
		const ZOOM_SPEED: float = 0.1
		const ZOOM_MIN: float = 0.5
		const ZOOM_MAX: float = 2.0
		var camera = $camera
		var step = ZOOM_SPEED * Input.get_axis("zoom_out", "zoom_in")
		camera.zoom.x = clamp(camera.zoom.x * (1.0 + step), ZOOM_MIN, ZOOM_MAX)
		camera.zoom.y = clamp(camera.zoom.y * (1.0 + step), ZOOM_MIN, ZOOM_MAX)

func _physics_process(_delta: float) -> void:
	var base_speed = (self.speed if self.state != PlayerState.ROLL else self.roll_speed) + (5.0 * self.speed_stat)
	for effect in self.effects.values():
		if 'speed' in effect:
			base_speed *= effect['speed']
	self.velocity = self.movement.normalized() * base_speed
	self.move_and_slide()

func _update_mana(delta):
	self.mana += self.mana_per_second * delta
	self.mana = min(self.mana, self.max_mana)
	self._update_mana_ui()

func _update_mana_ui():
	self.mana_bar.max_value = self.max_mana
	self.mana_bar.value = self.mana

func _has_enough_mana(mana: float) -> bool:
	return self.mana - mana >= 0.0
	
func _use_mana(mana: float) -> bool:
	if self._has_enough_mana(mana):
		self.mana -= mana
		self._update_mana_ui()
		return true
	else:
		return false

func _compute_immunity(delta, active_sprite):
	const BLINK = 0.05
	self.immunity_timer += delta
	var color
	if self.immunity_timer > self.immunity_duration:
		color = Color.WHITE
	else:
		var t = self.immunity_timer / BLINK
		if int(t) % 2 == 0:
			color = Color.WHITE
		else:
			color = Color.TRANSPARENT
	active_sprite.modulate = color

func heal(heal: float):
	self.health += heal
	self.health = min(self.health, self.max_health)
	self._update_health_ui()
	
func make_intangible(intangible):
	if intangible:
		self.collision_mask = 0b111000
		self.collision_layer = 0b10000000
	else:
		self.collision_layer = 0b1
		self.collision_mask = (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5)
		
func has_hit_iframes() -> bool:
	return self.immunity_timer < self.immunity_duration
	
func has_roll_iframes() -> bool:
	if self.state == PlayerState.ROLL:
		var roll_state = self.roll_timer / self.roll_duration
		if roll_state >= self.roll_immunity_range.x and roll_state <= self.roll_immunity_range.y:
			return true
			
	return false

func has_iframes() -> bool:
	return self.has_hit_iframes() or self.has_roll_iframes()
	
func has_parry_frames() -> bool:	
	return self.parry_timer < self.parry_duration

# Returns a true, if the projectile should be destroyed
func deal_damage(damage: float) -> bool:
	if self.has_iframes() or damage == 0.0:
		return false

	self.immunity_timer = 0.0
	self.health -= damage
	$hurt_audio.play()
	if self.health <= 0.0:
		self._death()
	self._update_health_ui()
	return true
	
func _death():
	inventory.visible = false
	var game_over = self.GAME_OVER.instantiate()
	self.game.add_child(game_over)
	
func _update_health_ui():
	var health_bar := $ui/hud/health_bar
	health_bar.max_value = self.max_health
	health_bar.value = self.health
	
func _level_up():
	$level_up.restart()
	$level_up_audio.play()
	$level_up_animation.play('level_up')
	self.skill_tokens += 1
	self.level_up_tokens += 1
	
func _use_potion():
	if 1 > self.potions:
		return
		
	if self.health >= self.max_health:
		return

	self.potions -= 1
	self.heal(self.max_health / 3.0)
	$potion_audio.play()
	self._update_potion_ui()

func refill_potion(amount: int):
	self.potions += amount
	self.potions = min(self.potions, self.max_potions)
	self._update_potion_ui()
	
func _update_potion_ui():
	var sprite := $ui/hud/potion/sprite
	var amount: Label = $ui/hud/potion/amount
	if self.potions == 0:
		sprite.region_rect.position.x = sprite.region_rect.size.x
		amount.visible = false
	else:
		sprite.region_rect.position.x = 0
		amount.visible = true
		amount.text = int_to_roman(self.potions)
	
func int_to_roman(num: int) -> String:
	const ROMAN_NUMERALS := {
		10: "X", 9: "IX", 5: "V", 4: "IV", 1: "I"
	}
	var result := ""
	for value in ROMAN_NUMERALS.keys():
		while num >= value:
			result += ROMAN_NUMERALS[value]
			num -= value
	
	return result

func attack_factor(_type: Projectile.DamageType) -> float:
	var base_attack = 1.0 + self.attack_stat * 0.16
	for effect in self.effects.values():
		if 'attack' in effect:
			base_attack *= effect['attack']
	return base_attack
	
func assign_attack(slot: PlayerAttackSlot, attack):
	var slot_string = slot_to_string(slot)
	var attack_ui = self.get_node('ui/hud/attack/' + slot_string)
	var attack_slot = self.get_node('ui/inventory/character/content/attack_slots/' + slot_string)
	if attack == null:
		self.active_attacks[slot] = null
		attack_slot.icon = null
		attack_ui.texture = null	
		attack_ui.visible = false
		return
	assert('unlocked' in attack)
	if slot_to_type(slot) != attack['type']:
		push_error('Wrong attack type for slot!')
		return
	
	var icon = attack['icon']
	attack_slot.icon = icon
	attack_ui.texture = icon
	attack_ui.visible = true
	
	self.active_attacks[slot] = attack


func decrease_stat(property: String):
	self[property] -= 1
	
	match property:
		'health_stat':
			self.max_health -= 10.0

func increase_stat(property: String):
	self[property] += 1
	match property:
		'health_stat':
			self.max_health += 10.0
