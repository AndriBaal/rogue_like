extends CanvasLayer


func _ready() -> void:
	$return.pressed.connect(self._return)
	$retry.pressed.connect(self._retry)
	self.get_tree().paused = true
	
func _return():
	self.get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
func _retry():
	Menu.LOAD_SAVE = false
	self.get_tree().paused = false
	self.get_tree().change_scene_to_file("res://scenes/loading_screen.tscn")
