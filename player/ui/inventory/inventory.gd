extends NinePatchRect

class_name Inventory


func _ready() -> void:
	$close.pressed.connect(self._close)


func _close():
	self.visible = false


func make_active(node_name: String):
	for child in self.get_children():
		if child.name == "close":
			continue
		child.get_node("content").visible = false
		child.get_node("navigation").self_modulate = Color.WHITE

	var active = self.get_node(node_name)
	active.get_node("content").visible = true
	active.get_node("navigation").self_modulate = Color("657392")
