extends CharacterBody2D

class_name BaseEnemy

enum EnemyState {
	IDLE,
	ATTACKING,
	MOVING
}

@export var max_health: float = 15.0
@export var health: float = 15.0
@export var attack_radius: float = 400.0
@export var attack_speed: float = 1.4
@export var movement_speed: float = 200.0
@export var attack_sprite: Sprite2D
var target_vector: Vector2
# TODO: melee damage

@onready var game = $/root/game
@onready var target = $/root/game/player/body

var animation_timer := 0.0

var state := EnemyState.IDLE
var movement: Vector2
var direction: Utils.Direction = Utils.Direction.south()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if self.health <= 0.0:
		self.queue_free()
		return
	
	var target_position = target.position
	var position_delta: Vector2 = target_position - self.global_position
	var distance = position_delta.length()
	self.target_vector = position_delta.normalized()
	
	var new_state
	if self.state == EnemyState.ATTACKING and self.animation_timer > self.attack_speed:
		if distance > self.attack_radius:
			new_state = EnemyState.MOVING
		else:
			self.state = EnemyState.IDLE
			new_state = EnemyState.ATTACKING
	elif distance > self.attack_radius and self.state != EnemyState.ATTACKING:
		new_state = EnemyState.MOVING
	else:
		new_state = EnemyState.ATTACKING
	
	if new_state != self.state:
		if self.attack_sprite:
			self.attack_sprite.visible = false
		$idle_sprite.visible = false
		$walk_sprite.visible = false
		self.animation_timer = 0.0
		self.movement = Vector2.ZERO
		match new_state:
			EnemyState.IDLE:
				$idle_sprite.visible = true
			EnemyState.ATTACKING:
				self.start_attack()
				self.attack_sprite.visible = true
			EnemyState.MOVING:
				$walk_sprite.visible = true
		self.state = new_state
		
	
	self.direction = Utils.Direction.from_vector(position_delta)
	
	var active_sprite
	match self.state:
		EnemyState.IDLE:
			active_sprite = $idle_sprite
		EnemyState.ATTACKING:
			active_sprite = self.attack_sprite
			active_sprite.frame_coords.x = int(active_sprite.hframes / self.attack_speed  * self.animation_timer) % active_sprite.hframes
			self.animation_timer += delta
			self.attack()
			
		EnemyState.MOVING:
			active_sprite = $walk_sprite
			active_sprite.frame_coords.x = int(self.animation_timer * 16.0) % active_sprite.hframes
			self.animation_timer += delta
			self.movement = position_delta.normalized()
			
	active_sprite.frame_coords.y = self.direction.inner

func _physics_process(delta: float) -> void:
	self.velocity = self.movement.normalized() * self.movement_speed
	var res = self.move_and_slide()

func start_attack() -> void:
	self.movement = Vector2.ZERO
	self.attack_sprite = $idle_attack_sprite
	
func attack():
	pass
	
