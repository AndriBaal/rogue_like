extends Enemy

class_name GoblinAxe

var attacked := false
const AXE := preload("res://projectiles/axe.tscn")


func loot_pool() -> Array:
	return [
		{"scene": BRONZE_COIN, "chance": 1.0, "amount": Vector2i(0, 6)},
		{"scene": SILVER_COIN, "chance": 1.0, "amount": Vector2i(0, 4)},
		{"scene": GOLD_COIN, "chance": 1.0, "amount": Vector2i(0, 2)},
	]


func start_attack() -> void:
	super()
	$throw_sound.play()
	self.attacked = false


func attack():
	super()
	if not self.attacked and self.attack_sprite.frame_coords.x == 8:
		self.attacked = true
		self.game.spawn_projectile(
			AXE.instantiate(), self.global_position + 80.0 * self.target_vector, self.target_vector
		)
