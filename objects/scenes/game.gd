extends Node2D

class_name Game

@onready var projectiles = $projectiles
	
	
func spawn_projectile(projectile, origin: Vector2, target: Vector2) -> void:
	var p = projectile.instantiate()
	p.start(origin, target)
	self.projectiles.add_child(p)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var room = load("res://objects/dungeons/goblin_dungeon/enemy_room1.tscn").instantiate()
	room.position += Vector2(100.0, 0.0)
	self.add_child(room)
