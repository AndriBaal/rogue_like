extends Node2D

class_name Game

@onready var projectiles = $projectiles
@onready var effects = $effects
@onready var ui_effects = $ui_effects
@onready var player: Player = $player
@onready var attack_selection = $player/ui/inventory/character/content/attack_selection

const POP_UP := preload("res://ui/pop_up.tscn")

var mouse_wheel_delta := 0.0

func spawn_pop_up(title, description):
	var pop_up = POP_UP.instantiate()
	pop_up.start(title, description)
	$player/ui.add_child(pop_up)

func spawn_projectile(projectile, origin: Vector2, target: Vector2, friendly: bool = false) -> void:
	projectile.start(friendly, origin, target)
	self.projectiles.add_child(projectile)
	projectile.set_owner($/root/game)
	
func _process(_delta: float) -> void:
	self.mouse_wheel_delta = 0.0
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
			mouse_wheel_delta += 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
			mouse_wheel_delta -= 1
