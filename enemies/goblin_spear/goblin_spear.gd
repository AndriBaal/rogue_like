extends Enemy

var attacked := false
const WOOD_SPEAR := preload("res://projectiles/wood_spear.tscn")


func loot_pool() -> Array:
	return [
		{"scene": BRONZE_COIN, "chance": 1.0, "amount": Vector2i(0, 3)},
		{"scene": SILVER_COIN, "chance": 1.0, "amount": Vector2i(0, 2)},
		{"scene": GOLD_COIN, "chance": 1.0, "amount": Vector2i(0, 1)},
	]


func start_attack() -> void:
	super()
	self.attacked = false


func attack():
	super()
	if not self.attacked and self.attack_sprite.frame_coords.x == 8:
		self.attacked = true
		$throw_sound.play()
		self.game.spawn_projectile(
			WOOD_SPEAR.instantiate(),
			self.global_position + 80.0 * self.target_vector,
			self.target_vector
		)
