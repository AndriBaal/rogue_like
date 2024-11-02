extends CharacterBody2D

class_name Enemy

enum EnemyState {
	INACTIVE,
	AGGRO,
	ATTACKING,
	MOVING
}

const HIT_ANIMATION_DURATION := 0.25

const DESPAWN := preload("res://enemies/despawn.tscn")
const BRONZE_COIN := preload("res://items/coin/bronze_coin.tscn")
const SILVER_COIN := preload("res://items/coin/silver_coin.tscn")
const GOLD_COIN := preload("res://items/coin/gold_coin.tscn")
const DAMAGE_NUMBER := preload("res://enemies/damage_number.tscn")

@onready var game: Game = $/root/game
@onready var target = $/root/game/player
@onready var navigation := $navigation
@onready var hp_bar := %hp_bar

@export var max_health: float = 12.0
@export var health: float = 12.0:
	get:
		return health
	set(value):
		health = value
		%hp_bar.value = health
		if health <= 0.0:
			target.xp += xp
			call_deferred("death")
			
@export var attack_radius: float = 400.0
@export var attack_speed: float = 1.4
@export var movement_speed: float = 200.0
@export var melee_damage: float = 5.0
@export var attack_sprite: Sprite2D
@export var hit_animation_timer := HIT_ANIMATION_DURATION
@export var xp: int = 20

@export var animation_timer := 0.0
@export var target_vector: Vector2
@export var state := EnemyState.INACTIVE
@export var movement: Vector2
@export var direction := Direction.SOUTH

@export var hp_bar_offset := Vector2.ZERO


func _ready() -> void:
	self.navigation.velocity_computed.connect(self._velocity_computed)
	$path_calculation.timeout.connect(self._calc_path_to_target)
	
	self.hp_bar_offset = self.hp_bar.global_position
	self.hp_bar.position += self.global_position
	self.hp_bar.max_value = self.health
	
func aggro() -> void:
	self.state = EnemyState.AGGRO

func _process(delta: float) -> void:
	var active_sprite
	match self.state:
		EnemyState.INACTIVE:
			active_sprite = $idle_sprite
			return
		EnemyState.ATTACKING:
			active_sprite = self.attack_sprite
			active_sprite.frame_coords.x = int(active_sprite.hframes / self.attack_speed  * self.animation_timer) % active_sprite.hframes
			self.animation_timer += delta
			self.attack()
			self.direction = Direction.from_vector(self.target_vector)
		EnemyState.MOVING:
			active_sprite = $walk_sprite
			active_sprite.frame_coords.x = int(self.animation_timer * 16.0) % active_sprite.hframes
			self.animation_timer += delta
			self.direction = Direction.from_vector(self.movement)
	
	if active_sprite:
		active_sprite.frame_coords.y = self.direction
		self._compute_hit_animation(delta, active_sprite)
		
	$hp_bar.position = self.global_position + self.hp_bar_offset

func _physics_process(_delta: float) -> void:
	if self.state == EnemyState.INACTIVE:
		return
		
	var target_position = target.global_position
	var position_delta: Vector2 = target_position - self.global_position
	var distance = position_delta.length()
	self.target_vector = position_delta.normalized()
	
	var new_state
	if self.state == EnemyState.ATTACKING and self.animation_timer > self.attack_speed:		
		if distance <= self.attack_radius and self._target_visible():
			self.state = EnemyState.INACTIVE # TODO: Refactor this
			new_state = EnemyState.ATTACKING
		else:
			new_state = EnemyState.MOVING
	elif distance <= self.attack_radius and self._target_visible() or self.state == EnemyState.ATTACKING:
		new_state = EnemyState.ATTACKING
	else:
		new_state = EnemyState.MOVING
	
	if new_state != self.state:
		self.state_changed(self.state, new_state)

	match self.state:
		EnemyState.INACTIVE:
			return
		EnemyState.MOVING:
			var current_agent_position: Vector2 = self.global_position
			var next_path_position: Vector2 = self.navigation.get_next_path_position()
			self.movement = current_agent_position.direction_to(next_path_position)
		_ :
			self.movement = Vector2.ZERO
		
	self.navigation.max_speed = self.movement_speed
	self.navigation.velocity = self.movement.normalized() * self.movement_speed

func _target_visible():
	const OFFSET := 50;
	
	var right_offset = self.movement.rotated(PI / 2) * (OFFSET / 2)
	var left_offset = self.movement.rotated(-PI / 2) * (OFFSET / 2)
	
	var space_state = self.get_world_2d().direct_space_state
	var left_result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(self.global_position + left_offset, self.target.global_position + left_offset))
	var right_result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(self.global_position + right_offset, self.target.global_position + right_offset))
	
	return left_result and right_result and left_result.collider == self.target and right_result.collider == self.target

func _calc_path_to_target():
	if self.state == EnemyState.MOVING:
		self.navigation.target_position = self.target.position

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
	if self.state == EnemyState.INACTIVE: # Prevent player from cheesing inactive enemy
		return
		
	if health <= 0.0: # Enemy is already dead
		return
		
	var damage_number = DAMAGE_NUMBER.instantiate()
	damage_number.start(self.global_position, damage)
	self.game.ui_effects.add_child(damage_number)
	
	self.health -= damage
	self.hit_animation_timer = 0.0

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
			const ITEM_SPREAD := 150.0
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

func _velocity_computed(safe: Vector2):
	self.velocity = safe
	var res = self.move_and_slide()
	if res:
		for i in range(self.get_slide_collision_count()):
			var collision = self.get_slide_collision(i)
			#var collider = collision.get_collider()
			if collision.get_collider_id() == self.target.get_instance_id():
				self.target.deal_damage(self.melee_damage)

func attack():
	pass

func state_changed(_old_state: EnemyState, new_state: EnemyState) -> void:
	if self.attack_sprite:
		self.attack_sprite.visible = false
	$idle_sprite.visible = false
	$walk_sprite.visible = false
	self.animation_timer = 0.0
	self.movement = Vector2.ZERO
	match new_state:
		EnemyState.INACTIVE:
			$idle_sprite.visible = true
		EnemyState.ATTACKING:
			self.start_attack()
			self.attack_sprite.visible = true
		EnemyState.MOVING:
			self._calc_path_to_target()
			$walk_sprite.visible = true
	self.state = new_state
	
func loot_pool() -> Array:
	return []

	
