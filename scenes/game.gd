extends Node2D

class_name Game

@onready var projectiles = $projectiles
	
	
func spawn_projectile(projectile, origin: Vector2, target: Vector2, friendly: bool = false) -> void:
	var p = projectile.instantiate()
	p.start(friendly, origin, target)
	self.projectiles.add_child(p)

func _ready() -> void:
	pass
