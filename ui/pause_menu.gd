extends CanvasLayer

func _ready() -> void:
	$continue.pressed.connect(self._continue)
	$save.pressed.connect(self._save)
	$quit.pressed.connect(self._quit)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		self._continue()
		
func _continue():
	self.visible = !self.visible
	self.get_tree().paused = self.visible

func _quit():
	self._save()
	self.get_tree().paused = false
	self.get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
func _save():
	var current_scene = $/root/game
	_set_owner(current_scene, current_scene)
	var packed_scene = PackedScene.new()
	var pack_result = packed_scene.pack(current_scene)
	if pack_result != OK:
		push_error('Error while packing the scene!')

	var save_result = ResourceSaver.save(packed_scene, "user://%s.scn" % Menu.GAME_NAME)
	if save_result != OK:
		push_error('Error while saving the scene!')


func _set_owner(node, root):
	if node != root:
		node.owner = root
	for child in node.get_children():
		_set_owner(child, root)
