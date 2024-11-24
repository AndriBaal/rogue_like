extends Enemy

class_name Skelton

const BONE := preload("res://projectiles/bone.tscn")
var attacked := false


func loot_pool() -> Array:
	return [
		{"scene": SILVER_COIN, "chance": 1.0, "amount": Vector2i(0, 6)},
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
			BONE.instantiate(), self.global_position + 80.0 * self.target_vector, self.target_vector
		)

		self.game.spawn_projectile(
			BONE.instantiate(),
			self.global_position + 80.0 * self.target_vector,
			self.target_vector.rotated(deg_to_rad(20.0))
		)
		self.game.spawn_projectile(
			BONE.instantiate(),
			self.global_position + 80.0 * self.target_vector,
			self.target_vector.rotated(deg_to_rad(-20.0))
		)
