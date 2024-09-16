extends Node2D

class_name Game

@onready var projectiles = $projectiles

var fireball := preload("res://objects/projectiles/fireball.tscn")

func spawn_fireball(origin: Vector2, target: Vector2) -> void:
	var projectile = self.fireball.instantiate()
	projectile.start(origin, target)
	self.projectiles.add_child(projectile)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var room = load("res://objects/dungeons/goblin_dungeon/test_room.tscn").instantiate()
	room.position += Vector2(500.0, 0.0)
	self.add_child(room)
