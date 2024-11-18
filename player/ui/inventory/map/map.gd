extends Panel

class_name Map

@onready var teleporters := $cam/teleporters
@onready var tiles := $cam/tiles
@onready var map_player := $cam/player
@onready var player := $/root/game/player

@export var tile_size: Vector2
var last_mouse_pos := Vector2.ZERO

const SCALE := 10.0
const TELEPORT_BUTTON = preload('res://player/ui/inventory/map/teleport.tscn')

func _ready() -> void:
	$center_camera.pressed.connect(self._center_camera)
	self.visibility_changed.connect(self._visibility_changed)
	
func _visibility_changed():
	if self.visible:
		self._center_camera()
	
func _center_camera():
	var cam: Camera2D = $cam
	var a = self.get_global_rect().size / 2.0
	cam.position = Vector2(a.x, a.y)

func close_teleporters():
	for teleporter in self.teleporters.get_children():
		teleporter.disabled = true

func open_teleporters():
	for teleporter in self.teleporters.get_children():
		teleporter.disabled = false
	
func add_rect(cell, rect_color := Color.GRAY):
	var color_rect := ColorRect.new()
	color_rect.color = rect_color
	color_rect.size = cell.size * SCALE
	color_rect.position = cell.position * SCALE
	tiles.add_child(color_rect)
	
func add_teleport(teleport_position):
	var teleporter := TELEPORT_BUTTON.instantiate()		
	teleporter.position = teleport_position * SCALE - teleporter.get_global_rect().size / 2.0
	teleporter.teleport_position = Vector2(teleport_position) * tile_size + tile_size / 2.0
	teleporters.add_child(teleporter)

func _process(_delta: float) -> void:
	var mouse_pos = self.get_local_mouse_position()
	if self.visible and self.get_parent().visible:
		if mouse_pos.x > 0.0 and mouse_pos.y > 0.0:
			if Input.is_action_pressed("primary_attack"):
				$cam.position += mouse_pos - self.last_mouse_pos
			self.last_mouse_pos = mouse_pos
		var player_map_pos: Vector2 = self.player.global_position / self.tile_size * SCALE - self.map_player.size / 2.0
		self.map_player.position = player_map_pos
