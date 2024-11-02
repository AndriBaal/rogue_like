extends Item

class_name Coin

@export var value := 5

#const SCALE_X := 3.5
#const SCALE_SPEED: float = 7.5
#var current_scale: float = SCALE_X
#var scaling_direction: int = -1 # -1 to reduce, 1 to increase
#
#func _process(delta: float) -> void:
	#self.current_scale += self.scaling_direction * SCALE_SPEED * delta
	#
	#if self.current_scale <= -SCALE_X or self.current_scale >= SCALE_X:
		#self.scaling_direction *= -1
		#
	#self.scale.x = self.current_scale

func _on_collect():
	player.add_money(self.value) 
	$collect_audio.play()
	self.queue_free() 
