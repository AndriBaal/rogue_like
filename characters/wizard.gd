extends CharacterBody2D


enum PlayerState {
	IDLE,
	IDLE_ATTACK,
	WALK,
	WALK_ATTACK
}

@onready var game = $/root/game
@onready var camera = $camera
@onready var walk_sprite = $walk_sprite
@onready var walk_attack_sprite = $walk_attack_sprite
@onready var idle_sprite = $idle_sprite
@onready var idle_attack_sprite = $idle_attack_sprite
@onready var health_bar = $ui/health_bar
@onready var inventory = $ui/tabs


const XP_FOR_LVL_UP = 50
const ATTACK_SPEED := 0.5
const SPEED := 600.0
const IMMUNITY_SECONDS = 0.75

@export var direction := Direction.SOUTH
@export var state: PlayerState = PlayerState.IDLE
@export var movement: Vector2
@export var animation_timer := 0.0
@export var attack_timer := ATTACK_SPEED
@export var immunity_timer := IMMUNITY_SECONDS
@export var health := 20.0
@export var max_health := 20.0
@export var xp = 0
@export var level = 1

var fireball := preload("res://projectiles/fireball.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		self.inventory.visible = !self.inventory.visible
	
	
	self.attack_timer += delta
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

	if (Input.is_action_pressed("attack") or Input.is_action_pressed("alt_attack")) and not inventory.visible:
		var look: Vector2 = $/root/game.get_local_mouse_position()
		var look_direction: Vector2 = (look - player_position).normalized()
		new_direction = Direction.from_vector(look_direction)
		
		if is_moving:
			new_state = PlayerState.IDLE_ATTACK
		else:
			new_state = PlayerState.WALK_ATTACK
		
		if self.attack_timer >= ATTACK_SPEED:
			self.attack_timer = 0.0
			self.game.spawn_projectile(self.fireball, player_position + 80.0 * look_direction, look_direction, true)

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
			self.walk_sprite.frame_coords.x = int(self.animation_timer * 16.0) % self.walk_sprite.hframes
			self.animation_timer += delta
		PlayerState.WALK_ATTACK:
			active_sprite = self.walk_attack_sprite
			self.walk_attack_sprite.frame_coords.x = int(self.animation_timer * 16.0) % self.walk_sprite.hframes
			self.animation_timer += delta

	active_sprite.frame_coords.y = self.direction
	self._compute_immunity(delta, active_sprite)

	if Input.is_action_pressed("zoom_in"):
		self.camera.zoom += Vector2.ONE * delta

	if Input.is_action_pressed("zoom_out"):
		self.camera.zoom -= Vector2.ONE * delta
		
func _physics_process(delta: float) -> void:
	self.velocity = self.movement.normalized() * SPEED
	var res = self.move_and_slide()
	
func _compute_immunity(delta, active_sprite):
	const BLINK = 0.05
	self.immunity_timer += delta
	var color
	if self.immunity_timer > IMMUNITY_SECONDS:
		color = Color.WHITE
	else:
		var t = self.immunity_timer / BLINK
		if int(t) % 2 == 0:
			color = Color.WHITE
		else:
			color = Color.TRANSPARENT
	active_sprite.modulate = color

func deal_damage(damage: float):
	if self.immunity_timer < IMMUNITY_SECONDS:
		return

	self.immunity_timer = 0.0
	self.health -= damage
	$hurt_audio.play()
	if self.health <= 0.0:
		self.get_tree().change_scene_to_file("res://scenes/menu.tscn")
		return
	self.health_bar.value = self.health / self.max_health * 100.0

func gain_xp(xp: int):
	self.xp += xp
	if self.xp > XP_FOR_LVL_UP:
		var new_levels = int(self.xp / XP_FOR_LVL_UP)
		self.xp -= new_levels * XP_FOR_LVL_UP
		self.level += new_levels
		$ui/level.text = "LVL. %s" % self.level
	$ui/xp_bar.value = float(self.xp) / float(XP_FOR_LVL_UP) * 100.0
	
