extends Node2D

class_name Game

@onready var projectiles = $projectiles


func spawn_projectile(projectile, origin: Vector2, target: Vector2, friendly: bool = false) -> void:
	projectile.start(friendly, origin, target)
	self.projectiles.add_child(projectile)
	projectile.set_owner($/root/game)
