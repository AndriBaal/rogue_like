extends Area2D

class_name Item

enum ItemType {
	COIN,
	# TODO
}

@export var type := ItemType.COIN
@onready var player := $/root/game/player

func _ready() -> void:
	self.body_entered.connect(self._on_collision)

func _process(_delta: float) -> void:
	pass
	
func _on_collision(body):
	if body.get_instance_id() == self.player.get_instance_id():
		self._on_collect()
	
func _on_collect():
	pass
	
