extends CharacterBody2D

class_name Player

enum PlayerState {
	IDLE,
	IDLE_ATTACK,
	WALK,
	WALK_ATTACK,
	ROLL
}

@onready var game := $/root/game
@onready var camera := $camera
@onready var walk_sprite := $walk_sprite
@onready var walk_attack_sprite := $walk_attack_sprite
@onready var idle_sprite := $idle_sprite
@onready var idle_attack_sprite := $idle_attack_sprite
@onready var health_bar := $ui/health_bar
@onready var mana_bar := $ui/mana_bar
@onready var inventory := $ui/tabs

@export var xp_for_lvl_up := 50
@export var speed := 600.0
@export var immunity_seconds := 0.75

@export var direction := Direction.SOUTH
@export var state: PlayerState = PlayerState.IDLE
@export var movement: Vector2
@export var animation_timer := 0.0
@export var immunity_timer := immunity_seconds
@export var max_health := 20.0
@export var health := max_health
@export var xp := 0
@export var level := 1

@export var mana_per_second = 5.0
@export var max_mana := 50.0
@export var mana := max_mana
@export var attack_cooldowns := {
	'primary_attack': 0.0,
	'secondary_attack': 0.0,
	'ability1': 0.0,
	'ability2': 0.0,
}

@export var all_attacks := []
@export var attacks := {}

@export var max_potions := 3
@export var potions := max_potions
@export var heal_per_potion = 8

func _ready() -> void:
	self._update_potion_ui()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		self.inventory.visible = !self.inventory.visible
	
	self.movement = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	var new_state
	var new_direction := self.direction
	var player_position = self.position
	var is_moving := self.movement == Vector2.ZERO

	if is_moving:
		new_state = PlayerState.IDLE
	else:
		new_state = PlayerState.WALK
		new_direction = Direction.from_vector(self.movement)

	self._update_mana(delta)
	if Input.is_action_just_pressed("heal"):
		self._use_potion()
	
	for attack_type in self.attack_cooldowns:
		self.attack_cooldowns[attack_type] -= delta
	if not inventory.visible:
		for attack_type in self.attacks:
			if Input.is_action_pressed(attack_type):
				var attack = self.attacks[attack_type]
				if not attack:
					continue
				
				var look: Vector2 = $/root/game.get_local_mouse_position()
				var look_direction: Vector2 = (look - player_position).normalized()
				
				new_direction = Direction.from_vector(look_direction)
				if is_moving:
					new_state = PlayerState.IDLE_ATTACK
				else:
					new_state = PlayerState.WALK_ATTACK
						
				if self.attack_cooldowns[attack_type] <= 0.0 and self._use_mana(attack['mana_cost']):
					self.attack_cooldowns[attack_type] = attack['cool_down']
					attack['action'].call(player_position, look_direction)
					

	self.direction = new_direction

	if new_state != self.state:
		self.walk_sprite.visible = false
		self.idle_sprite.visible = false
		self.idle_attack_sprite.visible = false
		self.walk_attack_sprite.visible = false
		self.animation_timer = 0.0
		match new_state:
			PlayerState.IDLE_ATTACK:
				self.idle_attack_sprite.visible = true
			PlayerState.IDLE:
				self.idle_sprite.visible = true
			PlayerState.WALK:
				self.walk_sprite.visible = true
			PlayerState.WALK_ATTACK:
				self.walk_attack_sprite.visible = true

	self.state = new_state
	
	var active_sprite
	match self.state:
		PlayerState.IDLE:
			active_sprite = self.idle_sprite
		PlayerState.IDLE_ATTACK:
			active_sprite = self.idle_attack_sprite
		PlayerState.WALK:
			active_sprite = self.walk_sprite
			self.walk_sprite.frame_coords.x = int(self.animation_timer * 24.0) % self.walk_sprite.hframes
			self.animation_timer += delta
		PlayerState.WALK_ATTACK:
			active_sprite = self.walk_attack_sprite
			self.walk_attack_sprite.frame_coords.x = int(self.animation_timer * 24.0) % self.walk_sprite.hframes
			self.animation_timer += delta

	active_sprite.frame_coords.y = self.direction
	self._compute_immunity(delta, active_sprite)

	if Input.is_action_pressed("zoom_in"):
		self.camera.zoom += Vector2.ONE * delta

	if Input.is_action_pressed("zoom_out"):
		self.camera.zoom -= Vector2.ONE * delta
		
func _physics_process(delta: float) -> void:
	self.velocity = self.movement.normalized() * self.speed
	var res = self.move_and_slide()
	
func _update_mana(delta):
	self.mana += self.mana_per_second * delta
	self.mana = min(self.mana, self.max_mana)
	self._update_mana_ui()

func _update_mana_ui():
	self.mana_bar.value = self.mana / self.max_mana * 100.0

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

func deal_damage(damage: float):
	if self.immunity_timer < self.immunity_seconds:
		return

	self.immunity_timer = 0.0
	self.health -= damage
	$hurt_audio.play()
	if self.health <= 0.0:
		self.get_tree().change_scene_to_file("res://scenes/menu.tscn")
		return
	self._update_health_ui()

func _update_health_ui():
	self.health_bar.value = self.health / self.max_health * 100.0

func gain_xp(xp: int):
	self.xp += xp
	if self.xp > self.xp_for_lvl_up:
		var new_levels = int(self.xp / self.xp_for_lvl_up)
		self.xp -= new_levels * self.xp_for_lvl_up
		self.level += new_levels
		$ui/level.text = "LVL. %s" % self.level
	$ui/xp_bar.value = float(self.xp) / float(self.xp_for_lvl_up) * 100.0
	
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
	
func _update_potion_ui():
	var empty = $ui/health/empty
	var full = $ui/health/full
	var amount: Label = $ui/health/amount
	if self.potions == 0:
		empty.visible = true
		full.visible = false
		amount.visible = false
	else:
		empty.visible = false
		full.visible = true
		amount.visible = true
		amount.text = int_to_roman(self.potions)
	
func int_to_roman(num: int) -> String:
	const ROMAN_NUMERALS = {
		10: "X", 9: "IX", 5: "V", 4: "IV", 1: "I"
	}
	var result = ""
	
	for value in ROMAN_NUMERALS.keys():
		while num >= value:
			result += ROMAN_NUMERALS[value]
			num -= value
	
	return result
