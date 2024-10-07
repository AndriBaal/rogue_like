extends Enemy

var attacked := false
var wood_spear := preload("res://projectiles/wood_spear.tscn")

func loot_pool() -> Array:
	return [
		{
			'amount': 3,
			'scene': preload("res://items/coin/bronze_coin.tscn"),
			'drop_chance': 0.5
		},
		{
			'amount': 2,
			'scene': preload("res://items/coin/silver_coin.tscn"),
			'drop_chance': 0.5
		},
		{
			'amount': 1,
			'scene': preload("res://items/coin/gold_coin.tscn"),
			'drop_chance': 0.3
		},
	]

func start_attack() -> void:
	super()
	self.attacked = false

func attack():
	super()
	if not self.attacked and self.attack_sprite.frame_coords.x == 8:
		self.attacked = true
		self.game.spawn_projectile(
			self.wood_spear.instantiate(), self.global_position + 80.0 * self.target_vector, self.target_vector
		)
	
