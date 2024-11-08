extends Node2D

class_name Game

@onready var projectiles = $projectiles
@onready var effects = $effects
@onready var ui_effects = $ui_effects
@onready var player: Player = $player
@onready var attack_selection = $player/ui/inventory/character/content/attack_selection

const POP_UP := preload("res://ui/pop_up.tscn")

func is_valid_position(position: Vector2):
	for room in $rooms.get_children():
		var tilemap: TileMapLayer = room.get_node('tiles')
		var local = tilemap.local_to_map(tilemap.to_local(position))
		var tile_data = tilemap.get_cell_tile_data(local)
		if tile_data != null:
			if tile_data.get_collision_polygons_count(0) == 0:
				return true

	return false
		
		#var tile_coords = tile_map.world_to_map(world_position)
#
		#var tile_id = tile_map.get_cellv(tile_coords)
#
		#if tile_id != TileMap.INVALID_CELL:
			#print("Tile ID at mouse pointer on layer:", tile_map.name, "is", tile_id)
			#break

func play_track(path):
	pass

func spawn_pop_up(title, description):
	var pop_up = POP_UP.instantiate()
	pop_up.start(title, description)
	$player/ui.add_child(pop_up)

func spawn_projectile(projectile, origin: Vector2, target: Vector2, friendly: bool = false) -> void:
	projectile.start(friendly, origin, target)
	self.projectiles.add_child(projectile)
	projectile.set_owner($/root/game)
	
