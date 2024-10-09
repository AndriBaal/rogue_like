extends ColorRect

class_name Map

@onready var cam := $cam
@onready var teleporters := $cam/teleporters
@onready var tiles := $cam/tiles
@onready var map_player := $cam/player
@onready var player := $/root/game/player

@export var tile_size: Vector2
var last_mouse_pos := Vector2.ZERO


func _ready() -> void:
	pass


const SCALE := 10.0
const TELEPORT_BUTTON = preload('res://player/ui/inventory/map/teleport.tscn')

func close_teleporters():
	for teleporter in self.teleporters.get_children():
		teleporter.disabled = true

func open_teleporters():
	for teleporter in self.teleporters.get_children():
		teleporter.disabled = false
	
func add_rect(cell, tile_size, color := Color.WHITE):
	self.tile_size = tile_size
	var color_rect := ColorRect.new()
	color_rect.color = color
	color_rect.size = cell.size * SCALE
	color_rect.position = cell.position * SCALE
	tiles.add_child(color_rect)
	
func add_teleport(position):
	var teleporter := TELEPORT_BUTTON.instantiate()		
	teleporter.position = position * SCALE - teleporter.get_global_rect().size / 2.0
	teleporter.teleport_position = Vector2(position) * tile_size + tile_size / 2.0
	teleporters.add_child(teleporter)

func _process(_delta: float) -> void:
	var mouse_pos = self.get_local_mouse_position()
	if self.visible:
		if Input.is_action_pressed("primary_attack"):
			self.cam.position += mouse_pos - self.last_mouse_pos
		self.map_player.position = self.player.position / self.tile_size * SCALE - self.map_player.size / 2.0
		self.last_mouse_pos = mouse_pos
