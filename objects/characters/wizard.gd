extends CharacterBody2D


enum PlayerState {
	IDLE,
	IDLE_ATTACK,
	WALK,
	WALK_ATTACK
}

@onready var game = $/root/game
@onready var camera = $player_camera
@onready var walk_sprite = $walk_sprite
@onready var walk_attack_sprite = $walk_attack_sprite
@onready var idle_sprite = $idle_sprite
@onready var idle_attack_sprite = $idle_attack_sprite

var fireball := preload("res://objects/projectiles/fireball.tscn")

const ATTACK_SPEED := 0.5
const SPEED := 400.0

var direction: Utils.Direction = Utils.Direction.south()
var state: PlayerState = PlayerState.IDLE
var movement: Vector2
var animation_timer := 0.0
var attack_timer := ATTACK_SPEED


func _process(delta: float) -> void:
	self.attack_timer -= delta
	self.movement = Vector2.ZERO
	self.movement.x += Input.get_action_strength("move_right")
	self.movement.x -= Input.get_action_strength("move_left")
	self.movement.y -= Input.get_action_strength("move_up")
	self.movement.y += Input.get_action_strength("move_down")

	var new_state
	var new_direction := self.direction
	var player_position = self.position
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
		
		if self.attack_timer < 0.0:
			self.attack_timer = ATTACK_SPEED
			self.game.spawn_projectile(self.fireball, player_position + 80.0 * look_direction, look_direction)
		
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
			self.walk_sprite.frame_coords.x = int(self.animation_timer) % self.walk_sprite.hframes
			self.animation_timer += delta * 16.0
		PlayerState.WALK_ATTACK:
			active_sprite = self.walk_attack_sprite
			self.walk_attack_sprite.frame_coords.x = int(self.animation_timer) % self.walk_sprite.hframes
			self.animation_timer += delta * 16.0
			
	active_sprite.frame_coords.y = self.direction.inner
	
	if Input.is_action_pressed("zoom_in"):
		self.camera.zoom += Vector2.ONE * delta
		
	if Input.is_action_pressed("zoom_out"):
		self.camera.zoom -= Vector2.ONE * delta

func _physics_process(delta: float) -> void:
	self.velocity = self.movement.normalized() * SPEED
	var res = self.move_and_slide()
	
