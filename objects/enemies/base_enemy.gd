extends CharacterBody2D

class_name BaseEnemy

enum EnemyState {
	IDLE,
	ATTACKING,
	MOVING
}

@export var max_health: float = 200.0
@export var health: float = 200.0
@export var attack_radius: float = 400.0
@export var movement_speed: float = 200.0
# TODO: melee damage

@onready var game = $/root/game
@onready var player = $/root/game/player/player_body

var animation_timer := 0.0

var state := EnemyState.IDLE
var movement: Vector2
var direction: Utils.Direction = Utils.Direction.south()

func aggro():
	self.state = EnemyState.MOVING

func _ready() -> void:
	self.aggro()

func _process(delta: float) -> void:
	if self.health <= 0.0:
		self.queue_free()
		return
	
	var target_position = player.position
	var position_delta: Vector2 = target_position - self.global_position
	var distance = position_delta.length()
	
	var new_state
	if distance > self.attack_radius:
		new_state = EnemyState.MOVING
	else:
		new_state = EnemyState.IDLE
	
	if new_state != self.state:
		$idle_sprite.visible = false
		$idle_attack_sprite.visible = false
		$walk_sprite.visible = false
		self.animation_timer = 0.0
		self.movement = Vector2.ZERO
		match new_state:
			EnemyState.IDLE:
				$idle_sprite.visible = true
			EnemyState.ATTACKING:
				$idle_attack_sprite.visible = true
			EnemyState.MOVING:
				$walk_sprite.visible = true
		self.state = new_state
		
	
	self.direction = Utils.Direction.from_vector(position_delta)
	
	var active_sprite
	match self.state:
		EnemyState.IDLE:
			active_sprite = $idle_sprite
		EnemyState.ATTACKING:
			active_sprite = $idle_attack_sprite
			active_sprite.frame_coords.x = int(self.animation_timer) % active_sprite.hframes
			self.animation_timer += delta * 16.0
		EnemyState.MOVING:
			active_sprite = $walk_sprite
			active_sprite.frame_coords.x = int(self.animation_timer) % active_sprite.hframes
			self.animation_timer += delta * 16.0
			self.movement = position_delta.normalized()
			
	active_sprite.frame_coords.y = self.direction.inner

func _physics_process(delta: float) -> void:
	self.velocity = self.movement.normalized() * self.movement_speed
	var res = self.move_and_slide()

func attack() -> bool:
	return false
	
