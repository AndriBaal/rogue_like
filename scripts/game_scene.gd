extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var room = load("res://scenes/rooms/test_room.tscn").instantiate()
	room.position += Vector2(0.0, 0.0)
	self.add_child(room)
