
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
	
	func get_possible_rooms() -> Dictionary:
		match self.type:
			DungeonType.GOBLIN:
				return {
					'start': load('res://objects/dungeons/goblin_dungeon/test_room.tscn'),
					'bad': [
						load('res://objects/dungeons/goblin_dungeon/test_room.tscn'),
					],
					'good': [
						
					],
					'neutral_rooms': [
						
					]
				}
		return {}
		
class Dungeon:
	var rooms: Array[PackedScene]
	
	func _init(options: DungeonOptions) -> void:
		pass
		
