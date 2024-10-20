extends Enemy

class_name Slime


func state_changed(old_state: EnemyState, new_state: EnemyState) -> void:
	super(old_state, new_state)
	var trail: GPUParticles2D = $trail
	if new_state == EnemyState.MOVING:
		trail.visible = true
	else:
		trail.visible = true
