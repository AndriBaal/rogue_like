extends AnimatedSprite2D


func _ready() -> void:
	self.animation_finished.connect(self._finished)
	
func _finished():
	self.queue_free()
