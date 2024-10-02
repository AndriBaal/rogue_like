extends Player

var fire_ball = preload("res://projectiles/fire_ball.tscn")
var water_wave = preload("res://projectiles/water_wave.tscn")

const PROJECTILE_OFFSET := 80.0

func _ready():
	self.all_attacks = {
		'fire_ball': {
			'name': 'Fire Ball',
			'action': self._fire_ball,
			'mana_cost': 5.0,
			'cool_down': 0.5,
			'type': AttackType.PRIMARY,
			# TODO: icon
		},
		'water_wave': {
			'name': 'Water Wave',
			'action': self._water_wave,
			'mana_cost': 10.0,
			'cool_down': 1.0,
			'type': AttackType.PRIMARY
		},
		'fire_storm': {
			'name': 'Fire Storm',
			'action': self._fire_storm,
			'mana_cost': 15.0,
			'cool_down': 2.0,
			'type': AttackType.ABILITY
		},
		'fire_wall': {
			'name': 'Fire Wall',
			'action': self._fire_wall,
			'mana_cost': 20.0,
			'cool_down': 2.0,
			'type': AttackType.ABILITY
		}
	}
	self.attacks = {
		'primary_attack': self.all_attacks['fire_ball'],
		'secondary_attack': self.all_attacks['water_wave'],
		'ability1': self.all_attacks['fire_storm'],
		'ability2': self.all_attacks['fire_wall']
	}
	
	super()
	
func _fire_ball(player_position, look_direction):
	self.game.spawn_projectile(self.fire_ball.instantiate(), player_position + PROJECTILE_OFFSET * look_direction, look_direction, true)
	
func _water_wave(player_position, look_direction):
	self.game.spawn_projectile(self.water_wave.instantiate(), player_position + PROJECTILE_OFFSET * look_direction, look_direction, true)
	
func _fire_storm(player_position, _look_direction):
	const AMOUNT = 15
	var angle_step = TAU / AMOUNT  # TAU is 2 * PI (360 degrees in radians)
	for i in range(AMOUNT):
		var angle = i * angle_step
		var spawn_position = player_position + Vector2(cos(angle), sin(angle)) * PROJECTILE_OFFSET
		var direction_vector = Vector2(cos(angle), sin(angle)).normalized()
		var f = self.fire_ball.instantiate()
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
		var f = self.fire_ball.instantiate()
		f.max_age = 2.0
		self.game.spawn_projectile(f, spawn_position + PROJECTILE_OFFSET * direction_vector, direction_vector, true)
		
