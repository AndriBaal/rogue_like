extends CharacterBody2D

class_name Enemy

enum EnemyState {
	IDLE,
	AGGRO,
	ATTACKING,
	MOVING
}

const HIT_ANIMATION_DURATION := 0.25

const DESPAWN := preload("res://enemies/despawn.tscn")
const BRONZE_COIN = preload("res://items/coin/bronze_coin.tscn")
const SILVER_COIN = preload("res://items/coin/silver_coin.tscn")
const GOLD_COIN = preload("res://items/coin/gold_coin.tscn")

@onready var game = $/root/game
@onready var target = $/root/game/player
@onready var navigation := $navigation

@export var max_health: float = 12.0
@export var health: float = 12.0
@export var attack_radius: float = 400.0
@export var attack_speed: float = 1.4
@export var movement_speed: float = 200.0
@export var melee_damage: float = 5.0
@export var attack_sprite: Sprite2D
@export var hit_animation_timer := HIT_ANIMATION_DURATION
@export var xp: int = 20
@export var target_visible: bool = false

@export var animation_timer := 0.0
@export var target_vector: Vector2
@export var state := EnemyState.IDLE
@export var movement: Vector2
@export var direction := Direction.SOUTH


func _ready() -> void:
	$navigation.velocity_computed.connect(self.velocity_computed)
	
func aggro() -> void:
	self.state = EnemyState.AGGRO

func _process(delta: float) -> void:
	var target_position = target.global_position
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
	elif distance <= self.attack_radius and self.target_visible or self.state == EnemyState.ATTACKING:
		new_state = EnemyState.ATTACKING
	else:
		new_state = EnemyState.MOVING
	
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
	
	if self.state == EnemyState.ATTACKING:
		self.direction = Direction.from_vector(self.target_vector)
	else:
		self.direction = Direction.from_vector(self.movement)
	active_sprite.frame_coords.y = self.direction
	
	self._compute_hit_animation(delta, active_sprite)

func _physics_process(_delta: float) -> void:
	match self.state:
		EnemyState.IDLE:
			return
		EnemyState.MOVING:
			# TODO: Optimize do not pathfind every frame
			$navigation.target_position = target.position
			var current_agent_position: Vector2 = self.global_position
			var next_path_position: Vector2 = $navigation.get_next_path_position()
			self.movement = current_agent_position.direction_to(next_path_position)
		_ :
			self.movement = Vector2.ZERO
	
	const OFFSET := 50;
	var space_state = self.get_world_2d().direct_space_state
	
	var right_offset = self.movement.rotated(PI / 2) * (OFFSET / 2)
	var left_offset = self.movement.rotated(-PI / 2) * (OFFSET / 2)
	
	var left_result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(self.global_position + left_offset, self.target.global_position + left_offset))
	var right_result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(self.global_position + right_offset, self.target.global_position + right_offset))

	self.target_visible = left_result.collider == self.target and right_result.collider == self.target
			
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
		var color_scale = 1.0 - abs((self.hit_animation_timer / HIT_ANIMATION_DURATION) * 2.0 - 1.0)
		color = Color(1.0, 1.0 - color_scale, 1.0 - color_scale, 1.0)
	active_sprite.modulate = color
	
func deal_damage(damage: float):
	if self.health <= 0.0: # Enemy is already dead
		return
		
	if self.state == EnemyState.IDLE: # Prevent player from cheesing inactive enemy
		return
		
	self.health -= damage
	self.hit_animation_timer = 0.0
	if self.health <= 0.0:
		self.target.gain_xp(self.xp)
		self.call_deferred("death")

func death():
	self.queue_free()
	var d := self.DESPAWN.instantiate()
	d.position = self.global_position
	d.scale *= self.global_scale
	$/root/game/effects.add_child(d)
	
	for item in self.loot_pool():
		
		var chance = randf()
		if chance > item['chance']:
			continue
		var amount = item['amount']
		for _amount in range(amount.x, randi_range(amount.x, amount.y)):
			const ITEM_SPREAD := 75.0
			var i = item['scene'].instantiate()
			var offset := Vector2(
				randf_range(-ITEM_SPREAD, ITEM_SPREAD), 
				randf_range(-ITEM_SPREAD, ITEM_SPREAD)
			)
			i.position = self.global_position + offset
			$/root/game/items.add_child(i)

func start_attack() -> void:
	self.movement = Vector2.ZERO
	self.attack_sprite = $idle_attack_sprite
	
func velocity_computed(safe: Vector2):
	print(safe)
	
func attack():
	pass
	
func loot_pool() -> Array:
	return []

	
