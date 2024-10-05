extends GPUParticles2D


func _ready() -> void:
	self.finished.connect(self._finished)
	self.restart()
	
func _finished():
	self.queue_free()
