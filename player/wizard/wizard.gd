extends Player

const FIRE_BAll = preload("res://projectiles/fire_ball.tscn")
const WATER_WAVE = preload("res://projectiles/water_wave.tscn")
const ROCK = preload("res://projectiles/rock.tscn")

const PROJECTILE_OFFSET := 80.0

func _ready():
	self.attacks = {
		'fire_ball': {
			'name': 'Fire Ball',
			'description': 'aaa',
			'action': '_fire_ball',
			'mana_cost': 5.0,
			'cool_down': 0.5,
			'type': AttackType.PRIMARY,
			'icon': preload("res://player/ui/attacks/fire_ball.png")
		},
		'water_wave': {
			'name': 'Water Wave',
			'description': 'bbb',
			'action': '_water_wave',
			'mana_cost': 10.0,
			'cool_down': 1.0,
			'type': AttackType.PRIMARY,
			'icon': preload("res://player/ui/attacks/water_wave.png")
		},
		'fire_storm': {
			'name': 'Fire Storm',
			'description': 'aaa1',
			'action': '_fire_storm',
			'mana_cost': 15.0,
			'cool_down': 2.0,
			'type': AttackType.ABILITY,
			'icon': preload("res://player/ui/attacks/fire_storm.png")
		},
		'fire_wall': {
			'name': 'Fire Wall',
			'description': 'aaa2',
			'action': '_fire_wall',
			'mana_cost': 20.0,
			'cool_down': 2.0,
			'type': AttackType.ABILITY,
			'icon': preload("res://player/ui/attacks/fire_wall.png")
		},
		'rock_throw': {
			'name': 'Rockthrow',
			'description': 'ccc',
			'action': '_rock_throw',
			'mana_cost': 20.0,
			'cool_down': 2.0,
			'type': AttackType.PRIMARY,
			'icon': preload("res://player/ui/attacks/rock_throw.png")
		},
		# TODO
		#'counter': {
			#
		#}
	}
	
	self.skill_tree = [
		{
			'type': SkillTree.SkillType.ATTACK,
			'attack_name': 'fire_ball',
			'position': Vector2(-250.0, 150.0),
			'children': [
				{
					'type': SkillTree.SkillType.ATTACK,
					'attack_name': 'fire_storm',
					'position': Vector2(-300.0, 0.0),
					'children': []
				},
				{
					'type': SkillTree.SkillType.ATTACK,
					'attack_name': 'fire_wall',
					'position': Vector2(-200.0, 0.0),
					'children': [],
				}
			],
		},
		{
			'type': SkillTree.SkillType.ATTACK,
			'attack_name': 'water_wave',
			'position': Vector2(0.0, 150.0),
			'children': []
		},
		{
			'type': SkillTree.SkillType.ATTACK,
			'attack_name': 'rock_throw',
			'position': Vector2(250.0, 150.0),
			'children': []
		}
	]
	
	super()
	
func _fire_ball(player_position, look_direction):
	self.game.spawn_projectile(self.FIRE_BAll.instantiate(), player_position + PROJECTILE_OFFSET * look_direction, look_direction, true)
	
func _water_wave(player_position, look_direction):
	self.game.spawn_projectile(self.WATER_WAVE.instantiate(), player_position + PROJECTILE_OFFSET * look_direction, look_direction, true)

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
		
