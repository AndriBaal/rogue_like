extends Node


enum PlayerState {
	IDLE,
	IDLE_ATTACK,
	WALK,
	WALK_ATTACK
}

@onready var game = $/root/game
@onready var body = $body
@onready var camera = $body/player_camera
@onready var walk_sprite = $body/walk_sprite
@onready var walk_attack_sprite = $body/walk_attack_sprite
@onready var idle_sprite = $body/idle_sprite
@onready var idle_attack_sprite = $body/idle_attack_sprite
@onready var health_bar = $player_ui/health_bar

var fireball := preload("res://projectiles/fireball.tscn")

const ATTACK_SPEED := 0.5
const SPEED := 400.0
const IMMUNITY_SECONDS = 0.75

var direction: Utils.Direction = Utils.Direction.south()
var state: PlayerState = PlayerState.IDLE
var movement: Vector2
var animation_timer := 0.0
var attack_timer := ATTACK_SPEED
var immunity_timer := IMMUNITY_SECONDS
var health := 20.0
var max_health := 20.0

func _process(delta: float) -> void:
	self.attack_timer += delta
	self.movement = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	var new_state
	var new_direction := self.direction
	var player_position = self.body.position
	var is_moving := self.movement == Vector2.ZERO

	if is_moving:
		new_state = PlayerState.IDLE
	else:
		new_state = PlayerState.WALK
		new_direction = Utils.Direction.from_vector(self.movement)

	if Input.is_action_pressed("attack"):
		var look: Vector2 = $/root/game.get_local_mouse_position()
		var look_direction: Vector2 = (look - player_position).normalized()
		new_direction = Utils.Direction.from_vector(look_direction)
		
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

	active_sprite.frame_coords.y = self.direction.inner
	self._compute_immunity(delta, active_sprite)

	if Input.is_action_pressed("zoom_in"):
		self.camera.zoom += Vector2.ONE * delta

	if Input.is_action_pressed("zoom_out"):
		self.camera.zoom -= Vector2.ONE * delta

func _physics_process(delta: float) -> void:
	self.body.velocity = self.movement.normalized() * SPEED
	var res = self.body.move_and_slide()
	
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
	$body/hurt_audio.play()
	if self.health <= 0.0:
		print('player died')
	self.health_bar.value = self.health / self.max_health * 100.0
