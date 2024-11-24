extends Player

const FIRE_BAll = preload("res://projectiles/fire_ball.tscn")
const ICE_SPEAR = preload("res://projectiles/ice_spear.tscn")
const ICE_WAVE = preload("res://projectiles/ice_wave.tscn")
const ROCK = preload("res://projectiles/rock.tscn")
const BUFF_CIRCLE = preload("res://player/wizard/attacks/buff_circle/buff_circle.tscn")
const SPIKES = preload("res://dungeons/goblin_dungeon/decorations/spikes.tscn")

const PROJECTILE_OFFSET := 35.0

@export var roll_damage = null


func _ready():
	$sensor.body_entered.connect(self._body_entered)
	if self.init:
		return

	self.attacks = {
		"fire_ball":
		{
			"name": "Fire Ball",
			"description":
			"A single well-balanced ball of fire. Deals moderate Damage at a moderate Cooldown. No Mana Cost.",
			"action": "_fire_ball",
			"mana_cost": 0.0,
			"cool_down": 0.5,
			"type": AttackType.PRIMARY,
			"icon": preload("res://player/wizard/attacks/fire_ball.png")
		},
		"ice_wave":
		{
			"name": "Sonic Wave",
			"description":
			"A piercing wave of ice that moves at great speeds. Deals moderate Damage at a long Cooldown.",
			"action": "_ice_wave",
			"mana_cost": 15.0,
			"cool_down": 0.5,
			"type": AttackType.ABILITY,
			"icon": preload("res://player/wizard/attacks/ice_wave.png")
		},
		"ice_spear":
		{
			"name": "Icicle",
			"description":
			"Rapid fire piercing icicles. Deals minor Damage at a short Cooldown. No Mana Cost.",
			"action": "_ice_spear",
			"mana_cost": 0.0,
			"cool_down": 0.2,
			"type": AttackType.PRIMARY,
			"icon": preload("res://player/wizard/attacks/ice_spear.png")
		},
		"ice_teleport":
		{
			"name": "Freeze Flash",
			"description": "Re-locate to your cursor's position in an instant.",
			"action": "_ice_teleport",
			"mana_cost": 15.0,
			"cool_down": 3.0,
			"type": AttackType.ABILITY,
			"icon": preload("res://player/wizard/attacks/ice_teleport.png")
		},
		"ice_deflect":
		{
			"name": "Slippery Reversal",
			"description": "Re-direct a projectile attack back to the sender.",
			"action": "_ice_deflect",
			"mana_cost": 5.0,
			"cool_down": 0.4,
			"type": AttackType.ABILITY,
			"icon": preload("res://player/wizard/attacks/ice_deflect.png")
		},
		"fire_storm":
		{
			"name": "Inferno Ring",
			"description":
			"Release a wild circle of fire around you. Most effective when surrounded.",
			"action": "_fire_storm",
			"mana_cost": 25.0,
			"cool_down": 0.75,
			"type": AttackType.ABILITY,
			"icon": preload("res://player/wizard/attacks/fire_storm.png")
		},
		"fire_wall":
		{
			"name": "Heat Burst",
			"description":
			"Launch a concentrated burst of flames. Get close and personal for best effect.",
			"action": "_fire_wall",
			"mana_cost": 20.0,
			"cool_down": 0.5,
			"type": AttackType.ABILITY,
			"icon": preload("res://player/wizard/attacks/fire_wall.png")
		},
		"fire_buff":
		{
			"name": "Overclock",
			"description":
			"Summon a firey rage within you, boosting your metabolism to enhance speed and strength.",
			"action": "_fire_buff",
			"mana_cost": 25.0,
			"cool_down": 12.0,
			"type": AttackType.ABILITY,
			"icon": preload("res://player/wizard/attacks/fire_buff.png")
		},
		"rock_throw":
		{
			"name": "Boulder Sling",
			"description":
			"Launch a heavy-hitting boulder. Deals major Damage at a slow Cooldown. No Mana Cost.",
			"action": "_rock_throw",
			"mana_cost": 0.0,
			"cool_down": 1.25,
			"type": AttackType.PRIMARY,
			"icon": preload("res://player/wizard/attacks/rock_throw.png")
		},
		"rock_roll":
		{
			"name": "Rock & Roll",
			"description": "Morph into a rolling boulder and turn your foes into pancake.",
			"action": "_rock_roll",
			"mana_cost": 20.0,
			"cool_down": 0.5,
			"type": AttackType.ABILITY,
			"icon": preload("res://player/wizard/attacks/rock_roll.png")
		},
		"rock_spike":
		{
			"name": "Stalagmite Spikes",
			"description":
			"Let sharp spikes of rock rise from the ground and impale those unfortunate enough to step on them.",
			"action": "_rock_spike",
			"mana_cost":  25.0,
			"cool_down": 0.5,
			"type": AttackType.ABILITY,
			"icon": preload("res://player/wizard/attacks/rock_spike.png")
		},
		"rock_buff":
		{
			"name": "Grounding",
			"description":
			"Create a spot at your cursor to anchor to the ground and draw energy from the earth, greatly enhancing your strength.",
			"action": "_rock_buff",
			"mana_cost": 25.0,
			"cool_down": 12.0,
			"type": AttackType.ABILITY,
			"icon": preload("res://player/wizard/attacks/rock_buff.png")
		},
	}

	self.skill_tree = [
		{
			"attack_name": "fire_ball",
			"position": Vector2(-250.0, 150.0),
			"children":
			[
				{
					"attack_name": "fire_storm",
					"position": Vector2(-300.0, 0.0),
					"children":
					[
						{
							"attack_name": "fire_buff",
							"position": Vector2(-250.0, -150.0),
							"children": []
						},
					]
				},
				{
					"attack_name": "fire_wall",
					"position": Vector2(-200.0, 0.0),
					"children":
					[
						{
							"attack_name": "fire_buff",
							"position": Vector2(-250.0, -150.0),
							"children": []
						},
					],
				}
			],
		},
		{
			"attack_name": "ice_spear",
			"position": Vector2(0.0, 150.0),
			"children":
			[
				{
					"attack_name": "ice_deflect",
					"position": Vector2(-50.0, 0.0),
					"children":
					[
						{
							"attack_name": "ice_wave",
							"position": Vector2(0.0, -150.0),
							"children": []
						},
					]
				},
				{
					"attack_name": "ice_teleport",
					"position": Vector2(50.0, 0.0),
					"children":
					[
						{
							"attack_name": "ice_wave",
							"position": Vector2(0.0, -150.0),
							"children": []
						},
					],
				}
			]
		},
		{
			"attack_name": "rock_throw",
			"position": Vector2(250.0, 150.0),
			"children":
			[
				{
					"attack_name": "rock_roll",
					"position": Vector2(300.0, 0.0),
					"children":
					[
						{
							"attack_name": "rock_buff",
							"position": Vector2(250.0, -150.0),
							"children": []
						},
					]
				},
				{
					"attack_name": "rock_spike",
					"position": Vector2(200.0, 0.0),
					"children":
					[
						{
							"attack_name": "rock_buff",
							"position": Vector2(250.0, -150.0),
							"children": []
						},
					],
				}
			]
		},
	]

	super()


func _process(delta: float) -> void:
	super(delta)
	if self.state != PlayerState.ROLL:
		self.roll_damage = null
		self.roll_duration = DEFAULT_ROLL_SPEED

func _ice_spear(player_position, look_direction):
	self.game.spawn_projectile(
		self.ICE_SPEAR.instantiate(),
		player_position + PROJECTILE_OFFSET * look_direction,
		look_direction,
		true
	)
	
	$shoot_ice.play()


func _ice_teleport(_player_position, _look_direction):
	var mouse_pos = self.game.get_local_mouse_position()
	if game.is_valid_position(mouse_pos):
		self.position = mouse_pos
		self.reset_physics_interpolation()
		$teleport.restart()
		$parry.play()


func _ice_deflect(_player_position, _look_direction):
	self.parry_timer = 0.0
	$shoot_ice.play()


func _rock_buff(_player_position, _look_direction):
	var mouse_pos = self.game.get_local_mouse_position()
	if game.is_valid_position(mouse_pos, true):
		var circle = BUFF_CIRCLE.instantiate().start(mouse_pos)
		game.get_node("projectiles").add_child(circle)
		
		$shoot_rock.play()


func _rock_spike(_player_position, _look_direction):
	var mouse_pos = self.game.get_local_mouse_position()
	if game.is_valid_position(mouse_pos, true):
		var spikes = SPIKES.instantiate().make_friendly(mouse_pos)
		game.get_node("projectiles").add_child(spikes)
		
		$shoot_rock.play()


func _rock_roll(_player_position, _look_direction):
	self.roll_damage = 7.5
	self.roll_duration = 0.75
	self.effects["rock_roll"] = {"duration": 0.75, "color": Color(0.2, 0.2, 0.2)}
	
	$rock_roll.play()
	
	return PlayerState.ROLL


func _fire_ball(player_position, look_direction):
	self.game.spawn_projectile(
		self.FIRE_BAll.instantiate(),
		player_position + PROJECTILE_OFFSET * look_direction,
		look_direction,
		true
	)
	
	$shoot_fire.play()


func _ice_wave(player_position, look_direction):
	self.game.spawn_projectile(
		self.ICE_WAVE.instantiate(),
		player_position + PROJECTILE_OFFSET * look_direction,
		look_direction,
		true
	)
	
	$shoot_ice.play()
	$shoot_ice.play()
	$shoot_ice.play()


func _rock_throw(player_position, look_direction):
	self.game.spawn_projectile(
		self.ROCK.instantiate(),
		player_position + PROJECTILE_OFFSET * look_direction,
		look_direction,
		true
	)
	
	$shoot_rock.play()
	$shoot_rock.play()
	$shoot_rock.play()


func _fire_storm(player_position, _look_direction):
	const AMOUNT = 12
	var angle_step = TAU / AMOUNT  # TAU is 2 * PI (360 degrees in radians)
	for i in range(AMOUNT):
		var angle = i * angle_step
		var spawn_position = player_position + Vector2(cos(angle), sin(angle)) * PROJECTILE_OFFSET
		var direction_vector = Vector2(cos(angle), sin(angle)).normalized()
		var f = self.FIRE_BAll.instantiate()
		f.scale *= 2.0
		f.max_age = 1.0
		self.game.spawn_projectile(
			f, spawn_position + PROJECTILE_OFFSET * direction_vector, direction_vector, true
		)
	
	$shoot_fire.play()
	$shoot_fire.play()
	$shoot_fire.play()
	$shoot_fire.play()
	$shoot_fire.play()


func _fire_wall(player_position, look_direction):
	const ARC_ANGLE := 0.5
	const AMOUNT = 5
	var center_angle = look_direction.angle()
	var angle_step = ARC_ANGLE / (AMOUNT - 1)

	for i in range(AMOUNT):
		var angle = center_angle - (ARC_ANGLE / 2) + i * angle_step
		var spawn_position = player_position + Vector2(cos(angle), sin(angle)) * PROJECTILE_OFFSET
		var direction_vector = Vector2(cos(angle), sin(angle)).normalized()
		var f = self.FIRE_BAll.instantiate()
		f.max_age = 2.0
		self.game.spawn_projectile(
			f, spawn_position + PROJECTILE_OFFSET * direction_vector, direction_vector, true
		)
	
	$shoot_fire.play()
	$shoot_fire.play()
	$shoot_fire.play()


func _fire_buff(_player_position, _look_direction):
	self.effects["fire_buff"] = {"duration": 8.0, "attack": 1.25, "speed": 1.2, "color": Color.RED}
	
	$fire_buff.play()


func _body_entered(body):
	if self.state == PlayerState.ROLL and (body is Enemy or body is Boss) and self.roll_damage:
		body.deal_damage(self.roll_damage)
