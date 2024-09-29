extends CharacterBody2D

class_name BaseEnemy

enum EnemyState {
	IDLE,
	AGGRO,
	ATTACKING,
	MOVING
}

const HIT_ANIMATION_DURATION := 0.25

@export var max_health: float = 12.0
@export var health: float = 12.0
@export var attack_radius: float = 400.0
@export var attack_speed: float = 1.4
@export var movement_speed: float = 200.0
@export var melee_damage: float = 5.0
@export var attack_sprite: Sprite2D
@export var target_vector: Vector2
@export var hit_animation_timer := HIT_ANIMATION_DURATION
@export var xp: int = 20
# TODO: melee damage

@onready var game = $/root/game
@onready var target = $/root/game/player

@export var animation_timer := 0.0

@export var state := EnemyState.IDLE
@export var movement: Vector2
var direction := Direction.SOUTH

func _ready() -> void:
	pass
	
func aggro() -> void:
	self.state = EnemyState.AGGRO

func _process(delta: float) -> void:
	var target_position = target.position
	var position_delta: Vector2 = target_position - self.global_position
	var distance = position_delta.length()
	self.target_vector = position_delta.normalized()
	
	var new_state
	if self.state == EnemyState.IDLE:
		return
	elif self.state == EnemyState.ATTACKING and self.animation_timer > self.attack_speed:
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
		
	
	self.direction = Direction.from_vector(position_delta)
	
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
			
	self._compute_hit_animation(delta, active_sprite)
	active_sprite.frame_coords.y = self.direction

func _physics_process(delta: float) -> void:
	self.velocity = self.movement.normalized() * self.movement_speed
	var res = self.move_and_slide()
	if res:
		for i in range(self.get_slide_collision_count()):
			var collision = self.get_slide_collision(i)
			if collision.get_collider_id() == self.target.get_instance_id():
				self.target.deal_damage(self.melee_damage)
	
func _compute_hit_animation(delta, active_sprite):
	self.hit_animation_timer += delta
	var color
	if self.hit_animation_timer > HIT_ANIMATION_DURATION:
		color = Color.WHITE
	else:
		var scale = 1.0 - abs((self.hit_animation_timer / HIT_ANIMATION_DURATION) * 2.0 - 1.0)
		color = Color(1.0, 1.0 - scale, 1.0 - scale, 1.0)
	active_sprite.modulate = color
	
func deal_damage(damage: float):
	if self.state == EnemyState.IDLE: # Prevent player from cheesing inactive 
		return
	self.health -= damage
	self.hit_animation_timer = 0.0
	if self.health <= 0.0:
		self.target.gain_xp(self.xp)
		self.queue_free()

func start_attack() -> void:
	self.movement = Vector2.ZERO
	self.attack_sprite = $idle_attack_sprite
	
func attack():
	pass
	
