extends Button


func _ready():
	self.pressed.connect(self._button_pressed)

func _button_pressed():
	self.get_tree().change_scene_to_file("res://objects/scenes/loading_screen.tscn")
