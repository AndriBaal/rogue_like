class_name DungeonGeneration

enum DungeonType {
	GOBLIN
}

class DungeonOptions:
	var type: DungeonType
	var seed: int
	var good_rooms: int
	var bad_rooms: int
	var neutral_rooms: int
	var min_room_spacing: float
	var hallway_width: float
	var max_bruteforce_tries: int
	var possible_rooms: Dictionary
	
	func _init(
		type: DungeonType,
		good_rooms: int,
		bad_rooms: int,
		neutral_rooms: int,
		min_room_spacing: float = 200.0,
		hallway_width: float = 100.0,
		seed: int = randi(),
		max_bruteforce_tries: int = 10000
	):
		self.type = type
		self.seed = seed
		self.good_rooms = good_rooms
		self.bad_rooms = bad_rooms
		self.neutral_rooms = neutral_rooms
		self.hallway_width = hallway_width
		self.min_room_spacing = min_room_spacing
	
		match self.type:
			DungeonType.GOBLIN:
				self.possible_rooms = {
					'start': load('res://dungeons/goblin_dungeon/enemy_room1.tscn'),
					'bad': [
						load('res://dungeons/goblin_dungeon/enemy_room1.tscn'),
					],
					'good': [
						
					],
					'neutral_rooms': [
						
					],
					'boss': load('res://dungeons/goblin_dungeon/enemy_room1.tscn')
				}

	func get_tile_map() -> void:
		pass # todo


		
class Dungeon:
	var rooms: Array[Node]
	var rng := RandomNumberGenerator.new()
	var good_rooms_left: int
	var bad_rooms_left: int
	var neutral_rooms_left: int
	var boss_rooms_left: int = 1
	

	func _init(options: DungeonOptions) -> void:
		self.rng.seed = options.seed

		self.good_rooms_left = options.good_rooms
		self.bad_rooms_left = options.bad_rooms
		self.neutral_rooms_left = options.neutral_rooms

		var starting_room = options.possible_rooms['start'].instantiate()
		self._close_room(starting_room, self._get_room_entrances(starting_room))
		self.rooms = [starting_room]

	func _recurse_grow_rooms():
		pass


	func _grow_room(force_once: bool) -> Array:
		var new_rooms = []



		return []
		
	func _close_room(room, entrances):
		var tilemap: TileMapLayer = room.get_node('tiles')
		for entrance in entrances:
			for tile in [entrance['start'], entrance['end']]:
				var tile_data := tilemap.get_cell_tile_data(tile)
				var entrance_layer_data = tile_data.get_custom_data('entrance_layer')
				if not entrance_layer_data:
					continue
					
				tilemap.set_cell(tile, 1, Vector2i.ZERO, tilemap.get_cell_alternative_tile(tile))

	func _generate_hallway(start, end) -> void:
		pass

	func _get_room_entrances(room) -> Array:
		const ENTRANCE_DATA_LAYER := 'entrance_layer'
		var tilemap: TileMapLayer = room.get_node('tiles')
		var rect = tilemap.get_used_rect()
		var entrances = []

		for x in range(rect.position.x, rect.end.x):
			for y in range(rect.position.y, rect.end.y):
				var coords = Vector2i(x, y)
				var tile_data = tilemap.get_cell_tile_data(coords)
				if not tile_data:
					continue
				var entrance_layer_data = tile_data.get_custom_data('entrance_layer')
				if not entrance_layer_data:
					continue

				for neighbour in [Vector2i(1, 0), Vector2i(0, 1)]:
					var cell = tilemap.get_cell_tile_data(coords + neighbour)
					if not cell:
						continue

					entrance_layer_data = cell.get_custom_data('entrance_layer')
					if entrance_layer_data:
						entrances.push_back({
							'start': coords,
							'end': coords + neighbour,
							'direction': Vector2i(0, 0)
						})
						break
						
		
		return entrances
