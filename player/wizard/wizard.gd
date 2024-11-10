extends Player

const FIRE_BAll = preload("res://projectiles/fire_ball.tscn")
const ICE_SPEAR = preload("res://projectiles/ice_spear.tscn")
const ICE_WAVE = preload("res://projectiles/ice_wave.tscn")
const ROCK = preload("res://projectiles/rock.tscn")

const PROJECTILE_OFFSET := 35.0

func _ready():
	if self.init:
		return
		
	self.attacks = {
		'fire_ball': {
			'name': 'Fire Ball',
			'description': 'aaa',
			'action': '_fire_ball',
			'mana_cost': 0.0,
			'cool_down': 0.5,
			'type': AttackType.PRIMARY,
			'icon': preload("res://player/wizard/attacks/fire_ball.png")
		},
		'ice_wave': {
			'name': 'Ice Wave',
			'description': 'bbb',
			'action': '_ice_wave',
			'mana_cost': 10.0,
			'cool_down': 0.5,
			'type': AttackType.ABILITY,
			'icon': preload("res://player/wizard/attacks/ice_wave.png")
		},
		'ice_spear': {
			'name': 'Ice Spear',
			'description': 'bbb',
			'action': '_ice_spear',
			'mana_cost': 0.0,
			'cool_down': 0.4,
			'type': AttackType.PRIMARY,
			'icon': preload("res://player/wizard/attacks/ice_spear.png")
		},
		'ice_teleport': {
			'name': 'Ice Teleport',
			'description': 'bbb',
			'action': '_ice_teleport',
			'mana_cost': 10.0,
			'cool_down': 1.0,
			'type': AttackType.ABILITY,
			'icon': preload("res://player/wizard/attacks/ice_teleport.png")
		},
		'ice_deflect': {
			'name': 'Ice Deflect',
			'description': 'bbb',
			'action': '_ice_deflect',
			'mana_cost': 10.0,
			'cool_down': 1.0,
			'type': AttackType.ABILITY,
			'icon': preload("res://player/wizard/attacks/ice_deflect.png")
		},
		'fire_storm': {
			'name': 'Fire Storm',
			'description': 'aaa1',
			'action': '_fire_storm',
			'mana_cost': 15.0,
			'cool_down': 2.0,
			'type': AttackType.ABILITY,
			'icon': preload("res://player/wizard/attacks/fire_storm.png")
		},
		'fire_wall': {
			'name': 'Fire Wall',
			'description': 'aaa2',
			'action': '_fire_wall',
			'mana_cost': 20.0,
			'cool_down': 2.0,
			'type': AttackType.ABILITY,
			'icon': preload("res://player/wizard/attacks/fire_wall.png")
		},
		'rock_throw': {
			'name': 'Rock Throw',
			'description': 'ccc',
			'action': '_rock_throw',
			'mana_cost': 20.0,
			'cool_down': 2.0,
			'type': AttackType.PRIMARY,
			'icon': preload("res://player/wizard/attacks/rock_throw.png")
		},
		'rock_roll': {
			'name': 'Rock Roll',
			'description': 'ccc',
			'action': '_rock_roll',
			'mana_cost': 20.0,
			'cool_down': 2.0,
			'type': AttackType.ABILITY,
			'icon': preload("res://player/wizard/attacks/rock_roll.png")
		},
		'rock_spike': {
			'name': 'Rock Spike',
			'description': 'ccc',
			'action': '_rock_spike',
			'mana_cost': 20.0,
			'cool_down': 2.0,
			'type': AttackType.ABILITY,
			'icon': preload("res://player/wizard/attacks/rock_spike.png")
		},
	}
	
	self.skill_tree = [
		{
			'attack_name': 'fire_ball',
			'position': Vector2(-250.0, 150.0),
			'children': [
				{
					'attack_name': 'fire_storm',
					'position': Vector2(-300.0, 0.0),
					'children': []
				},
				{
					'attack_name': 'fire_wall',
					'position': Vector2(-200.0, 0.0),
					'children': [],
				}
			],
		},
		{
			'attack_name': 'ice_spear',
			'position': Vector2(0.0, 150.0),
			'children': [
				{
					'attack_name': 'ice_deflect',
					'position': Vector2(-50.0, 0.0),
					'children': [
						{
							'attack_name': 'ice_wave',
							'position': Vector2(0.0, -150.0),
							'children': []
						},
					]
				},
				{
					'attack_name': 'ice_teleport',
					'position': Vector2(50.0, 0.0),
					'children': [
						{
							'attack_name': 'ice_wave',
							'children': []
						},
					],
				}
			]
		},
		{
			'attack_name': 'rock_throw',
			'position': Vector2(250.0, 150.0),
			'children': [
				{
					'attack_name': 'rock_roll',
					'position': Vector2(300.0, 0.0),
					'children': []
				},
				{
					'attack_name': 'rock_spike',
					'position': Vector2(200.0, 0.0),
					'children': [],
				}
			]
		},
	]
	
	super()
	
func _ice_spear(player_position, look_direction):
	self.game.spawn_projectile(self.ICE_SPEAR.instantiate(), player_position + PROJECTILE_OFFSET * look_direction, look_direction, true)
	
func _ice_teleport(player_position, look_direction):
	var mouse_pos = self.game.get_local_mouse_position()
	if game.is_valid_position(mouse_pos):
		self.position = mouse_pos
		$teleport.restart()
	
func _ice_deflect(player_position, look_direction):
	self.parry_timer = 0.0
	
func _rock_wall(player_position, look_direction):
	pass
	
func _rock_spike(player_position, look_direction):
	pass
	
func _rock_roll(player_position, look_direction):
	pass
	
func _fire_ball(player_position, look_direction):
	self.game.spawn_projectile(self.FIRE_BAll.instantiate(), player_position + PROJECTILE_OFFSET * look_direction, look_direction, true)
	
func _ice_wave(player_position, look_direction):
	self.game.spawn_projectile(self.ICE_WAVE.instantiate(), player_position + PROJECTILE_OFFSET * look_direction, look_direction, true)

func _rock_throw(player_position, look_direction):
	self.game.spawn_projectile(self.ROCK.instantiate(), player_position + PROJECTILE_OFFSET * look_direction, look_direction, true)
	
func _fire_storm(player_position, _look_direction):
	const AMOUNT = 15
	var angle_step = TAU / AMOUNT  # TAU is 2 * PI (360 degrees in radians)
	for i in range(AMOUNT):
		var angle = i * angle_step
		var spawn_position = player_position + Vector2(cos(angle), sin(angle)) * PROJECTILE_OFFSET
		var direction_vector = Vector2(cos(angle), sin(angle)).normalized()
		var f = self.FIRE_BAll.instantiate()
		f.scale *= 1.5
		f.max_age = 1.0
		self.game.spawn_projectile(f, spawn_position + PROJECTILE_OFFSET * direction_vector, direction_vector, true)
	
func _fire_wall(player_position, look_direction):
	const ARC_ANGLE := 1.0
	const AMOUNT = 5
	var center_angle = look_direction.angle()
	var angle_step = ARC_ANGLE / (AMOUNT - 1)
	
	for i in range(AMOUNT):
		var angle = center_angle - (ARC_ANGLE / 2) + i * angle_step
		var spawn_position = player_position + Vector2(cos(angle), sin(angle)) * PROJECTILE_OFFSET
		var direction_vector = Vector2(cos(angle), sin(angle)).normalized()
		var f = self.FIRE_BAll.instantiate()
		f.max_age = 2.0
		self.game.spawn_projectile(f, spawn_position + PROJECTILE_OFFSET * direction_vector, direction_vector, true)
		
