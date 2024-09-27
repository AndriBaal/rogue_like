extends CanvasLayer

func _ready() -> void:
	$continue.pressed.connect(self._continue)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		self._continue()
		
func _continue():
	self.visible = !self.visible
	self.get_tree().paused = self.visible
