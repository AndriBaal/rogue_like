extends CharacterBody2D

class_name Boss

enum BossState {
	INACTIVE,
	ATTACKING,
}

const WAIT_TIME := 1.0
const HIT_ANIMATION_DURATION := 0.25
const DAMAGE_NUMBER := preload("res://enemies/damage_number.tscn")
const DARK_FIRE := preload("res://projectiles/dark_fire_ball.tscn")
const PROJECTILE_OFFSET := 35.0

@onready var game: Game = $/root/game
@onready var target = $/root/game/player

@export var max_health: float = 500.0
@export var health: float = 500.0:
	get:
		return health
	set(value):
		health = value
		$hp_bar_layer/hp_bar.value = health
		if health <= 0.0:
			target.xp += xp
			call_deferred("death")

@export var movement_speed: float = 900.0
@export var melee_damage: float = 10.0
@export var attack_sprite: Sprite2D
@export var hit_animation_timer := HIT_ANIMATION_DURATION
@export var xp: int = 5

@export var state := BossState.INACTIVE
@export var init := false
@export var alive := true
@export var direction := Direction.SOUTH
@export var movement: Vector2
@export var target_vector: Vector2
@export var wait_timer := WAIT_TIME * 1.5
@export var active_attack = null
@export var attack_data := {}
@export var attacks := [
	{
		'start': '_start_move',
		'update': '_update_move'
	},
	{
		'start': '_start_attack1',
		'update': '_update_attack1'
	},
	{
		'start': '_start_attack2',
		'update': '_update_attack2'
	},
]

func make_sprite_active(node):
	$default.visible = false
	$move.visible = false
	$attack1.visible = false
	$attack2.visible = false
	$attack3.visible = false
	$attack4.visible = false
	node.visible = true

func _start_move():
	const TARGET_POINTS := [
		Vector2(0, 0),
		Vector2(600, 0),
		Vector2(0, 600),
		Vector2(-600, 0),
		Vector2(0, -600),
		Vector2(500, 500),
		Vector2(-500, 500),
		Vector2(500, -500),
		Vector2(-500, -500),
	]
	
	var move = $move
	self.make_sprite_active($move)
	
	var destination
	while true:
		destination = TARGET_POINTS.pick_random()
		if destination != self.position:
			self.attack_data = {
				'destination': destination,
				'animation_x': 0.0
			}
			break
	
	var delta: Vector2 = destination - self.position
	self.movement = delta.normalized()
	move.frame_coords.y = Direction.from_vector(self.movement)
	move.frame_coords.x = 0

func _update_move(delta) -> bool:
	var destination = attack_data['destination']
	if self.position.distance_to(destination) < 10.0:
		attack_data['last_position'] = self.position
		return false

	var d: Vector2 = destination - self.position
	self.movement = d.normalized()
	attack_data['animation_x'] += delta * 18.0
	var move = $move
	move.frame_coords.x = min(move.hframes-1, int(attack_data['animation_x']))
	return true
	

func _start_attack1():
	var attack1 = $attack1
	self.make_sprite_active(attack1)
	self.attack_data = {
		'animation_x': 0,
		'offset': 0.0,
		'fired': false,
	}
	attack1.frame_coords.y = Direction.from_vector(self.target_vector)

func _update_attack1(delta) -> bool:
	attack_data['animation_x'] += delta * 6.0
	var attack1 = $attack1
	attack1.frame_coords.x = min(attack1.hframes-1, int(attack_data['animation_x']))
	if attack1.frame_coords.x == 8 and not attack_data['fired']:
		attack_data['fired'] = true
		const AMOUNT = 32
		const ANGLE_STEP = TAU / AMOUNT  # TAU is 2 * PI (360 degrees in radians)
		for i in range(AMOUNT):
			var angle = i * ANGLE_STEP + attack_data['offset']
			var spawn_position = self.global_position + Vector2(cos(angle), sin(angle)) * PROJECTILE_OFFSET
			var direction_vector = Vector2(cos(angle), sin(angle)).normalized()
			var f = DARK_FIRE.instantiate()
			self.game.spawn_projectile(
				f, spawn_position + PROJECTILE_OFFSET * direction_vector, direction_vector
			)
		if randi() % 2 == 0:
			attack_data['offset'] += ANGLE_STEP / 2.0
			attack_data['fired'] = false
			attack_data['animation_x'] = 3
	if int(attack_data['animation_x']) > attack1.hframes:
		return false
	return true
	

func _start_attack2():
	var attack2 = $attack2
	self.make_sprite_active(attack2)
	self.attack_data = {
		'animation_x': 0,
		'offset': 0.0,
		'fired': false,
		'fire_timer': 0.0,
	}

func _update_attack2(delta) -> bool:
	attack_data['animation_x'] += delta * 8.0
	var attack2 = $attack2
	attack2.frame_coords.x = min(attack2.hframes-1, int(attack_data['animation_x']))
	attack_data['fire_timer'] -= delta
	if attack2.frame_coords.x >= 5 and attack2.frame_coords.y <= 9 and attack_data['fire_timer'] < 0.0:
		attack_data['fire_timer'] = 0.1
		self.game.spawn_projectile(
			DARK_FIRE.instantiate(),
			self.global_position + 80.0 * self.target_vector,
			self.target_vector
		)
		if randi() % 3 == 0:
			attack_data['animation_x'] -= 1
	
	attack2.frame_coords.y = Direction.from_vector(self.target_vector)
	if int(attack_data['animation_x']) > attack2.hframes:
		return false
	return true

func _ready() -> void:
	$despawn.finished.connect(self.queue_free)
	if not init:
		init = true
		$hp_bar_layer/hp_bar.max_value = self.max_health
		$hp_bar_layer/hp_bar.value = self.health
	
func spawn() -> void:
	$hp_bar_layer.visible = true
	self.state = BossState.ATTACKING

func _process(delta: float) -> void:
	if not alive or self.state == BossState.INACTIVE:
		return


	var target = self.game.player
	var target_position = target.global_position
	var position_delta: Vector2 = target_position - self.global_position
	self.target_vector = position_delta.normalized()
	if self.wait_timer > 0.0:
		if self.wait_timer == self.WAIT_TIME:
			self.game.spawn_projectile(
				DARK_FIRE.instantiate(),
				self.global_position + PROJECTILE_OFFSET * self.target_vector,
				self.target_vector
			)

			if randi() % 2 == 0:
				self.game.spawn_projectile(
					DARK_FIRE.instantiate(),
					self.global_position + PROJECTILE_OFFSET * self.target_vector,
					self.target_vector.rotated(deg_to_rad(15.0))
				)
				self.game.spawn_projectile(
					DARK_FIRE.instantiate(),
					self.global_position + PROJECTILE_OFFSET * self.target_vector,
					self.target_vector.rotated(deg_to_rad(-15.0))
				)
		$default.frame_coords.y = Direction.from_vector(self.target_vector)
		self.wait_timer -= delta
		return
			
	if self.active_attack == null:
		var attack = self.attacks.pick_random()
		self.active_attack = attack
		self.call(attack['start'])

	var result = self.call(self.active_attack['update'], delta)
	if not result:
		self.make_sprite_active($default)
		self.movement = Vector2.ZERO
		self.active_attack = null
		self.wait_timer = WAIT_TIME

func _physics_process(_delta: float) -> void:
	if not alive or self.state == BossState.INACTIVE:
		return

	self.velocity = self.movement * self.movement_speed
	var res = self.move_and_slide()
	if res:
		for i in range(self.get_slide_collision_count()):
			var collision := self.get_slide_collision(i)
			#var collider = collision.get_collider()
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
	if self.state == BossState.INACTIVE: # Prevent player from cheesing inactive enemy
		return
		
	if health <= 0.0: # Enemy is already dead
		return
		
	var damage_number = DAMAGE_NUMBER.instantiate()
	damage_number.start(self.global_position, damage)
	self.game.ui_effects.add_child(damage_number)
	
	self.health -= damage
	self.hit_animation_timer = 0.0
	$hit_sound.play()


func death():
	self.alive = false	
	
	for child in self.get_children():
		if 'visible' in child:
			child.visible = false
	var despawn = $despawn
	despawn.visible = true
	despawn.restart()
	$collider.disabled = true
	$defeat_sound.play()
