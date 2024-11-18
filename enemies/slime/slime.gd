extends Enemy

class_name Slime

func loot_pool() -> Array:
	return [
		{"scene": BRONZE_COIN, "chance": 1.0, "amount": Vector2i(0, 5)},
	]

func state_changed(old_state: EnemyState, new_state: EnemyState) -> void:
	super(old_state, new_state)
	var trail: GPUParticles2D = $trail
	if new_state == EnemyState.MOVING:
		trail.visible = true
	else:
		trail.visible = true
