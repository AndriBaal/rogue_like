extends TabContainer

@onready var map_camera = $Map/cam
var last_mouse_pos := Vector2.ZERO

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	var mouse_pos = $Map.get_local_mouse_position()
	if self.current_tab == 1 and Input.is_action_pressed("attack"):
		map_camera.position += mouse_pos - self.last_mouse_pos
	self.last_mouse_pos = mouse_pos
