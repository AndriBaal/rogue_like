extends BaseEnemy

var attacked := false
var wood_spear := preload("res://projectiles/wood_spear.tscn")


func start_attack() -> void:
	super()
	self.attacked = false


func attack():
	super()
	if not self.attacked and self.attack_sprite.frame_coords.x == 8:
		self.attacked = true
		self.game.spawn_projectile(
			self.wood_spear, self.global_position + 80.0 * self.target_vector, self.target_vector
		)
