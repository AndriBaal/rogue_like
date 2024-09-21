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
					'start': load('res://objects/dungeons/goblin_dungeon/enemy_room1.tscn'),
					'bad': [
						load('res://objects/dungeons/goblin_dungeon/enemy_room1.tscn'),
					],
					'good': [
						
					],
					'neutral_rooms': [
						
					],
					'boss': load('res://objects/dungeons/goblin_dungeon/enemy_room1.tscn')
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

		self.rooms = [options.possible_rooms['start'].instantiate()]

	func _recurse_grow_rooms():
		pass


	func _grow_room(force_once: bool) -> Array:
		var new_rooms = []



		return []

	func get_room_entrances(room) -> Array:
		const ENTRANCE_DATA_LAYER := 0
		var entrances = []
		var tilemap = room.get_node('tile_map')
		var rect = tilemap.get_used_rect()

		for x in range(rect.position.x, rect.end.x):
			for y in range(rect.position.y, rect.end.y):
				var tile_data = tilemap.get_cell_tile_data(x, y)
				if tile_data:
					var is_layer_true = tile_data.get_custom_data(ENTRANCE_DATA_LAYER)
					if is_layer_true:
						pass # todo
		return entrances
