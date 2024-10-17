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

static func slot_to_string(slot: PlayerAttackSlot):
	match slot:
		PlayerAttackSlot.PRIMARY_ATTACK:
			return 'primary_attack'
		PlayerAttackSlot.ABILITY1:
			return 'ability1'
		PlayerAttackSlot.ABILITY2:
			return 'ability2'
		PlayerAttackSlot.ABILITY3:
			return 'ability3'
			
static func slot_to_type(slot: PlayerAttackSlot):
	match slot:
		PlayerAttackSlot.PRIMARY_ATTACK:
			return AttackType.PRIMARY
		PlayerAttackSlot.ABILITY1, PlayerAttackSlot.ABILITY2, PlayerAttackSlot.ABILITY3:
			return AttackType.ABILITY

enum AttackType {
	PRIMARY,
	ABILITY
}

enum PlayerState {
	IDLE,
	IDLE_ATTACK,
	WALK,
	WALK_ATTACK,
	ROLL
}

@onready var game: Game = $/root/game
@onready var camera := $camera
@onready var walk_sprite := $walk_sprite
@onready var walk_attack_sprite := $walk_attack_sprite
@onready var idle_sprite := $idle_sprite
@onready var roll_sprite := $roll_sprite
@onready var idle_attack_sprite := $idle_attack_sprite
@onready var mana_bar := $ui/mana_bar
@onready var inventory := $ui/inventory

@export var xp_for_lvl_up := 50
@export var speed := 600.0
@export var immunity_seconds := 0.75

@export var direction := Direction.SOUTH
@export var state: PlayerState = PlayerState.IDLE
@export var movement: Vector2
@export var animation_timer := 0.0
@export var immunity_timer := immunity_seconds
@export var max_health := 20.0:
	get:
		return max_health
	set(value):
		if value > max_health:
			var diff = max_health
			max_health = value
			heal(diff)
		else:
			max_health = value
			heal(0.0)
		
@export var health := max_health
@export var xp := 0
@export var level := 1

@export var mana_per_second = 5.0
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

@export var max_potions := 4
@export var potions := max_potions
@export var heal_per_potion = 8

@export var roll_duration := 0.55
@export var roll_speed := 750.0
@export var roll_timer := 0.0
@export var roll_immunity_range: Vector2 = Vector2(0.05, 0.95)

@export var money := 0

@export var health_stat := 1
@export var attack_stat := 1
@export var speed_stat := 1

@export var level_up_tokens := 5:
	get:
		return level_up_tokens
	set(val):
		level_up_tokens = val
		$ui/inventory/Character.update_level_up_token_ui(val)
@export var skill_tokens := 5:
	get:
		return skill_tokens
	set(val):
		skill_tokens = val
		$ui/inventory/SkillTree.update_skill_token_ui(val)


var game_over := preload("res://ui/game_over.tscn")

func _ready() -> void:
	self._update_potion_ui()
	$ui/inventory/SkillTree.init_tree(self.skill_tree, self.attacks)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		self.inventory.visible = !self.inventory.visible
	
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
	var roll := Input.is_action_just_pressed("roll")
	var mouse_pos: Vector2 = self.game.get_local_mouse_position()
	var look: Vector2 = (mouse_pos - player_position).normalized()
	

	self.roll_timer -= delta
	if roll or roll_timer >= 0.0:
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
			var attack_ui = self.get_node('ui/attack/' + slot_to_string(attack_slot))
			var occluder = attack_ui.get_node(^'occluder')
			var ratio = max(0.0, self.attack_cooldowns[attack_slot] / attack['cool_down'])
			occluder.scale.y = ratio
	if not inventory.visible and new_state != PlayerState.ROLL:
		for attack_slot in self.active_attacks:
			if Input.is_action_pressed(slot_to_string(attack_slot)):
				var attack = self.active_attacks[attack_slot]
				if not attack:
					continue
				
				new_direction = Direction.from_vector(look)
				if not is_moving:
					new_state = PlayerState.IDLE_ATTACK
				else:
					new_state = PlayerState.WALK_ATTACK
						
				if self.attack_cooldowns[attack_slot] <= 0.0 and self._use_mana(attack['mana_cost']):
					self.attack_cooldowns[attack_slot] = attack['cool_down']
					self.call(attack['action'], player_position, look)
					

	if new_state != self.state:
		self.walk_sprite.visible = false
		self.idle_sprite.visible = false
		self.idle_attack_sprite.visible = false
		self.walk_attack_sprite.visible = false
		self.roll_sprite.visible = false
		self.animation_timer = 0.0
		match new_state:
			PlayerState.ROLL:
				var particle = %roll_particle
				particle.restart()
				self.roll_timer = self.roll_duration
				self.roll_sprite.visible = true
				self.movement = new_movement if is_moving else look
				self.direction = Direction.from_vector(self.movement)
			PlayerState.IDLE_ATTACK:
				self.idle_attack_sprite.visible = true
			PlayerState.IDLE:
				self.idle_sprite.visible = true
			PlayerState.WALK:
				self.walk_sprite.visible = true
			PlayerState.WALK_ATTACK:
				self.walk_attack_sprite.visible = true

	if new_state != PlayerState.ROLL:
		self.direction = new_direction
		self.movement = new_movement
	self.state = new_state
	
	var active_sprite
	match self.state:
		PlayerState.ROLL:
			active_sprite = self.roll_sprite
			active_sprite.frame_coords.x = int(abs(self.roll_timer - self.roll_duration) / self.roll_duration * active_sprite.hframes)
			self.animation_timer += delta
		PlayerState.IDLE:
			active_sprite = self.idle_sprite
		PlayerState.IDLE_ATTACK:
			active_sprite = self.idle_attack_sprite
		PlayerState.WALK:
			active_sprite = self.walk_sprite
			active_sprite.frame_coords.x = int(self.animation_timer * 24.0) % active_sprite.hframes
			self.animation_timer += delta
		PlayerState.WALK_ATTACK:
			active_sprite = self.walk_attack_sprite
			active_sprite.frame_coords.x = int(self.animation_timer * 24.0) % active_sprite.hframes
			self.animation_timer += delta

	active_sprite.frame_coords.y = self.direction
	self._compute_immunity(delta, active_sprite)


	if not inventory.visible and self.game.mouse_wheel_delta:
		const ZOOM_SPEED: float = 1.0
		const ZOOM_MIN: float = 0.1
		const ZOOM_MAX: float = 5.0
		var zoom_change := self.game.mouse_wheel_delta * 0.1
		var new_zoom = camera.zoom * (1 + zoom_change)
		new_zoom.x = clamp(new_zoom.x, ZOOM_MIN, ZOOM_MAX)
		new_zoom.y = clamp(new_zoom.y, ZOOM_MIN, ZOOM_MAX)

		camera.zoom = new_zoom

func _physics_process(_delta: float) -> void:
	var speed = self.speed if self.state != PlayerState.ROLL else self.roll_speed
	self.velocity = self.movement.normalized() * speed
	self.move_and_slide()
	
func _update_mana(delta):
	self.mana += self.mana_per_second * delta
	self.mana = min(self.mana, self.max_mana)
	self._update_mana_ui()

func _update_mana_ui():
	self.mana_bar.max_value = self.max_mana
	self.mana_bar.value = self.mana

func _use_mana(mana) -> bool:
	if self.mana - mana >= 0.0:
		self.mana -= mana
		self._update_mana_ui()
		return true
	else:
		return false

func _compute_immunity(delta, active_sprite):
	const BLINK = 0.05
	self.immunity_timer += delta
	var color
	if self.immunity_timer > self.immunity_seconds:
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
	

func has_iframes() -> bool:
	if self.immunity_timer < self.immunity_seconds:
		return true
	
	if self.state == PlayerState.ROLL:
		var roll_state = self.roll_timer / self.roll_duration
		if roll_state >= self.roll_immunity_range.x and roll_state <= self.roll_immunity_range.y:
			return true
		
	return false

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
	var game_over = self.game_over.instantiate()
	self.game.add_child(game_over)
	
func _update_health_ui():
	var health_bar := $ui/health_bar
	health_bar.max_value = self.max_health
	health_bar.value = self.health

func gain_xp(xp: int):
	self.xp += xp
	var bar = $ui/xp/bar
	while self.xp > self.xp_for_lvl_up:
		self.xp -= self.xp_for_lvl_up
		self.level += 1
		self._level_up()
	bar.max_value = float(self.xp_for_lvl_up)
	bar.value = float(self.xp)
	$ui/xp/level.text = "LVL. %s" % self.level
	
func _level_up():
	self.skill_tokens += 1
	self.level_up_tokens += 1
	#self.skill_tree_node.add_tokens(1)
	#self.character_node.add_tokens(1)
	
func _use_potion():
	if self.potions == 0:
		return

	self.potions -= 1
	self.heal(self.heal_per_potion)
	self._update_potion_ui()

func refill_potion(amount: int):
	self.potions += amount
	self.potions = min(self.potions, self.max_potions)
	self._update_potion_ui()
	
# TODO: Refactor to potion UI
func _update_potion_ui():
	var flask := $ui/health/flask
	var amount: Label = $ui/health/amount
	if self.potions == 0:
		flask.region_rect.position.x = flask.region_rect.size.x
		amount.visible = false
	else:
		flask.region_rect.position.x = 0
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
	
func assign_attack(slot: PlayerAttackSlot, attack: Dictionary):
	assert('unlocked' in attack)
	if slot_to_type(slot) != attack['type']:
		push_error('Wrong attack type for slot!')
		return
	
	var icon = attack['icon']
	var slot_string = slot_to_string(slot)
	var attack_ui = self.get_node('ui/attack/' + slot_string)
	var attack_slot = self.get_node('ui/inventory/Character/attack_slots/' + slot_string)
	attack_slot.icon = icon
	attack_ui.texture = icon
	attack_ui.visible = true
	
	self.active_attacks[slot] = attack.duplicate()

func add_money(amount: int):
	self.money += amount
	self._update_money_ui()

func _update_money_ui():
	$ui/money/label.text = str(self.money)

func decrease_stat(property: String):
	self[property] -= 1
	
	match property:
		'health_stat':
			self.max_health -= 5.0

func increase_stat(property: String):
	self[property] += 1
	match property:
		'health_stat':
			self.max_health += 5.0
