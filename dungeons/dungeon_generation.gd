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
		min_room_spacing: float = 1,
		seed: int = randi(),
		hallway_width: float = 2,
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
						load('res://dungeons/goblin_dungeon/enemy_room1.tscn'),
					],
					'neutral_rooms': [
						load('res://dungeons/goblin_dungeon/enemy_room1.tscn'),
					],
					'boss': load('res://dungeons/goblin_dungeon/enemy_room1.tscn')
				}
		
class Dungeon:
	var rooms: Array[Dictionary]
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
		self.rooms = [
			{
				'room': starting_room,
				'children': []
			}
		]
		self._grow_room(self.rooms[0])

	func _grow_room(room):
		const WALL_TILES = 1
		const FLOOR_TILES = 0
		
		var r = room['room']
		var tilemap: TileMapLayer = r.get_node('tiles')
		var floor_tile_source = tilemap.tile_set.get_source(FLOOR_TILES)
		var floor_tile_amount = floor_tile_source.get_tiles_count()
		var entrances = self._get_room_entrances(r)
		var room_sum = self.good_rooms_left + self.bad_rooms_left + self.neutral_rooms_left + self.boss_rooms_left
		
		for entrance in entrances:
			if self.rng.randi_range(0, 1) > 0:
				for tile in [entrance['start'], entrance['end']]:
					tilemap.set_cell(tile, FLOOR_TILES, Vector2i.ZERO)
					var floor_tile = self.rng.randi_range(0, floor_tile_amount-1)
					for i in range(5):
						tilemap.set_cell(tile + i * entrance.direction, FLOOR_TILES, floor_tile_source.get_tile_id(floor_tile))

			else:
				for tile in [entrance['start'], entrance['end']]:
					tilemap.set_cell(tile, WALL_TILES, Vector2i.ZERO, tilemap.get_cell_alternative_tile(tile))

		
		#for child in room['children']:
			#self._grow_room(child)
		

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
						var alt = tilemap.get_cell_alternative_tile(coords)
						var flip_h = bool(alt & TileSetAtlasSource.TRANSFORM_FLIP_H)
						var flip_v = bool(alt & TileSetAtlasSource.TRANSFORM_FLIP_V)
						var transpose = bool(alt & TileSetAtlasSource.TRANSFORM_TRANSPOSE)
						
						var direction
						if transpose:
							if flip_h and flip_v:
								direction = Vector2i(1, 0)
							elif flip_v:
								direction = Vector2i(1, 0)
							elif flip_h:
								direction = Vector2i(-1, 0)
							else:
								direction = Vector2i(-1, 0)
						else:
							if flip_h and flip_v:
								direction = Vector2i(0, -1)
							elif flip_h:
								direction = Vector2i(0, -1)
							elif flip_v:
								direction = Vector2i(0, 1)
							else:
								direction = Vector2i(0, 1)
						entrances.push_back({
							'start': coords,
							'end': coords + neighbour,
							'direction': direction
						})
						break
						
		
		print(entrances)
		return entrances
