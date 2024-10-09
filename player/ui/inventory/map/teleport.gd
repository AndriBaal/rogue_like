extends Button

class_name Teleporter

@export var teleport_position: Vector2

func _ready() -> void:
	self.pressed.connect(self._on_click)


func _on_click():
	var player = $/root/game/player
	player.position = self.teleport_position	
