extends Node2D

class_name Room

@onready var map = $/root/game/player/ui/inventory/map/content
@onready var target = $/root/game/player
@onready var game: Game = $/root/game
@onready var enemies := $enemies
@onready var tiles : TileMapLayer = $tiles

@export var finished: bool = false
@export var active: bool = false
@export var teleporters := []
@export var optimized_cells: Array[Rect2]
@export var children := []
@export var parent = null
@export var entrances: Array
@export var init := false

func start() -> Room:
	self.entrances = self._get_room_entrances()
	return self


func _ready() -> void:
	if self.init:
		return
	self.init = true
	
	var tile_size = Vector2(self.tiles.tile_set.tile_size) * self.tiles.scale
	var used_cells = self.tiles.get_used_cells()
	var tile_position = Vector2i(self.position / tile_size)
	var floor_cells: Array[Vector2i] = []
	for cell in used_cells:
		var data := self.tiles.get_cell_tile_data(cell)
		if not data:
			continue
			
		var teleport = data.get_custom_data('teleport')
		var show_on_minimap = data.get_custom_data('show_on_minimap')

		if teleport:
			teleporters.push_back(cell + tile_position)

		if show_on_minimap:
			floor_cells.push_back(cell + tile_position)
	self.optimized_cells = self._optimize_cells(floor_cells)
	
	# Make sure children are accessible after deserialization by not storing the refrence but the path
	self.parent = self.parent.get_path() if self.parent != null else null
	var children = []
	for child in self.children:
		children.push_back(child.get_path())
	self.children = children


func _get_room_entrances() -> Array:
	var tilemap: TileMapLayer = $entrances
	var cells = tilemap.get_used_cells()
	var entrances = []

	for cell in cells:
		var tile_data = tilemap.get_cell_tile_data(cell)
		if not tile_data:
			continue
		var entrance_data = tile_data.get_custom_data("entrance")
		if not entrance_data:
			continue

		for neighbour in [TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE]:
			var neighbour_cell = tilemap.get_neighbor_cell(cell, neighbour)
			var neighbour_data = tilemap.get_cell_tile_data(neighbour_cell)
			if not neighbour_data:
				continue

			entrance_data = neighbour_data.get_custom_data("entrance")
			if not entrance_data:
				continue

			var alt = tilemap.get_cell_alternative_tile(cell)
			var direction = DungeonGeneration.Dungeon._get_direction_from_alt(alt)

			(
				entrances
				. push_back(
					{
						"start": cell,
						"end": neighbour_cell,
						"direction": direction,
						"has_connection": false,
					}
				)
			)
			break
	return entrances

func _optimize_cells(cells: Array[Vector2i]) -> Array[Rect2]:
	var processed_cells: Array[Vector2i] = []
	var rects: Array[Rect2] = []
	var all_cells_in_row = func(start_x: int, end_x: int, y: int) -> bool:
		for x in range(start_x, end_x + 1):
			if Vector2i(x, y) not in cells or Vector2i(x, y) in processed_cells:
				return false
		return true

	# Sort cells first by y and then by x to make grouping easier
	cells.sort()

	for cell in cells:
		if cell in processed_cells:
			continue
		
		# Start forming a rectangle from the current cell
		var start = cell
		var width = 1
		var height = 1
		
		# Try to extend the rectangle horizontally (rightwards)
		while Vector2i(start.x + width, start.y) in cells and Vector2i(start.x + width, start.y) not in processed_cells:
			width += 1

		# Try to extend the rectangle vertically (downwards) while all cells in the row are filled
		while all_cells_in_row.call(start.x, start.x + width - 1, start.y + height):
			height += 1

		# Mark all cells within the formed rectangle as processed
		for x in range(start.x, start.x + width):
			for y in range(start.y, start.y + height):
				processed_cells.append(Vector2i(x, y))

		# Add the rectangle to the list
		rects.append(Rect2(Vector2(start), Vector2(width, height)))

	return rects

func _process(_delta: float) -> void:
	if finished:
		return
		
	var player_pos = self.target.position - self.position
	var player_tile_pos = self.tiles.local_to_map(player_pos / self.tiles.scale)
	
	if not self.active and self.tiles.get_used_rect().has_point(player_tile_pos):
		var tile_data = self.tiles.get_cell_tile_data(player_tile_pos)
		if not tile_data:
			return
		var entrance_data = tile_data.get_custom_data("entrance")
		if not entrance_data:
			self.active = true
			self._close_room()
			for enemy in self.enemies.get_children():
				enemy.aggro()
		
	if not self.active:
		return
		
	if self.cleared():
		self._open_room()
		self.active = false
		self.finished = true
		
					
	#if not active:
		#var player_size = self.target.get_node(^'collider').shape.get_rect().size * self.target.scale / 2.0
		#for entrance in self.entrances:
			#var direction = entrance['direction']
			#for v in [entrance['start'], entrance['end']]:
				#var tile = v - direction
				#var player_tile = self.tiles.local_to_map((player_pos - Vector2(-direction) * player_size) / self.tiles.scale)
				#if tile == player_tile:
					#self.active = true
					#self._close_room()
					#for enemy in self.enemies.get_children():
						#enemy.aggro()
					#return
					
func _close_room():
	if self.enemies.get_child_count() > 0:
		self.game.play_track('battle')
	
	map.close_teleporters()
	
	# Clear all projectiles on room enter
	for child in self.game.projectiles.get_children():
		child.queue_free()
	
	for entrance in self.entrances:
		if not entrance['has_connection']:
			continue
		for tile in [entrance["start"], entrance["end"]]:
			var atlas = self.tiles.get_cell_atlas_coords(tile) - Vector2i(1, 0)
			var alt = self.tiles.get_cell_alternative_tile(tile)
			self.tiles.set_cell(
				tile, DungeonGeneration.TILE_ID, atlas, alt
			)
			

func _open_room():
	self.game.play_track('relaxed')

	map.open_teleporters()
	for cell in self.optimized_cells:
		map.add_rect(cell, Color.LIGHT_GRAY)
		
	for path in self.children:
		var child = self.get_node(path)
		for cell in child.optimized_cells:
			map.add_rect(cell, Color.DIM_GRAY)
		
	for teleport in self.teleporters:
		map.add_teleport(teleport)
		
	if not self.active:
		return
		
	for entrance in self.entrances:
		if not entrance['has_connection']:
			continue
		for tile in [entrance["start"], entrance["end"]]:
			var atlas = self.tiles.get_cell_atlas_coords(tile) + Vector2i(1, 0)
			var alt = self.tiles.get_cell_alternative_tile(tile)
			self.tiles.set_cell(
				tile, DungeonGeneration.TILE_ID, atlas, alt
			)
			
func entrances_left() -> int:
	var left = 0
	for entrance in self.entrances:
		if not entrance['has_connection']:
			left += 1
	return left

func cleared() -> bool:
	var enemies_left = self.enemies.get_child_count()
	if enemies_left == 0:
		for attack in self.game.player.active_attacks.values():
			if attack != null:
				if self.name == 'boss_room':
					self.game.spawn_pop_up('Congratulations!', 'Thank you for playing our Game!')
				return true
	
	return false
