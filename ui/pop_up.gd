extends NinePatchRect


func _ready() -> void:
	self.get_tree().paused = true
	$close.pressed.connect(self._close)

func start(title, description):
	$title.text = title
	$description.text = description
	return self

func _close():
	self.get_tree().paused = false
	self.queue_free()
