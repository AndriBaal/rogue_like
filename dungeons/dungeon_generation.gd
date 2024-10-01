class_name DungeonGeneration

enum DungeonType { GOBLIN }
const WALL_TILES = 1
const FLOOR_TILES = 0


class DungeonOptions:
	var type: DungeonType
	var random_seed: int
	#var size: Vector2i
	var rooms_left: Dictionary
	var possible_rooms: Dictionary

	func _init(
		type: DungeonType,
		good_rooms: int,
		bad_rooms: int,
		neutral_rooms: int,
		#size: Vector2i = Vector2i(100, 100),
		random_seed: int = randi(),
	):
		self.type = type
		self.random_seed = random_seed
		#self.size = size
		self.rooms_left = {
			"good": good_rooms,
			"bad": bad_rooms,
			"neutral": neutral_rooms,
			"boss": 0,  # TODO: Change to 1
		}

		match self.type:
			DungeonType.GOBLIN:
				self.possible_rooms = {
					"start": load("res://dungeons/goblin_dungeon/starting_room.tscn"),
					"bad":
					[
						load("res://dungeons/goblin_dungeon/enemy_room.tscn"),
					],
					"good":
					[
						load("res://dungeons/goblin_dungeon/starting_room.tscn"),
					],
					"neutral":
					[
						load("res://dungeons/goblin_dungeon/starting_room.tscn"),
					],
					"boss": load("res://dungeons/goblin_dungeon/enemy_room.tscn")
				}


class Dungeon:
	var options: DungeonOptions
	var rooms_left: Dictionary
	var tile_size: Vector2
	var rooms: Array[Dictionary] = []
	var random := RandomNumberGenerator.new()

	func _init(options: DungeonOptions):
		self.options = options
		self.random.seed = options.random_seed
		self.rooms_left = options.rooms_left.duplicate(true)

		var room = options.possible_rooms["start"].instantiate()
		var tilemap: TileMapLayer = room.get_node("tiles")
		self.tile_size = Vector2(tilemap.tile_set.tile_size) * tilemap.scale

		#var size = self.options.size - rect.size
		#var pos = Vector2(
		#self.random.randi_range(-size.x, size.x),
		#self.random.randi_range(-size.y, size.y),
		#)
		#room.position = pos * self.tile_size

		room = {
			"room": room,
			"entrances": self._get_room_entrances(room),
			"children": [],
			#"parent": null,
		}
		self.rooms.push_back(room)
		self._grow_rooms(self.rooms, true)

	func shuffle_array(arr):
		for i in range(arr.size()):
			var random_index = self.random.randi_range(0, arr.size() - 1)
			arr.swap(i, random_index)  # Swap the current element with a random one

	func _rooms_left() -> int:
		var sum = 0
		for v in self.rooms_left:
			sum += self.rooms_left[v]
		return sum

	func _get_room_type(only_bad):
		var available_room_types = []
		if only_bad:
			available_room_types.push_back("bad")
		else:
			for key in self.rooms_left.keys():
				var value = self.rooms_left[key]
				if value:
					available_room_types.push_back(key)
		if available_room_types.is_empty():
			return null

		var room_type_key = available_room_types[self.random.randi_range(
			0, available_room_types.size() - 1
		)]  # TODO: Maybe add weighted random

		return room_type_key

	func _recurse_room_intersections(rooms, rect) -> bool:
		for room in rooms:
			var existing_r = room["room"]
			var existing_tile_map: TileMapLayer = existing_r.get_node("tiles")
			var existing_rect = existing_tile_map.get_used_rect()
			var existing_position_tile = Vector2i(existing_r.position / self.tile_size)
			existing_rect.position += existing_position_tile
			if rect.intersects(existing_rect):
				# TODO: Check for individual tiles
				return true
			if self._recurse_room_intersections(room["children"], rect):
				return true
		return false

	func _get_room(room_type_key):
		self.rooms_left[room_type_key] -= 1

		var possible_rooms = self.options.possible_rooms
		var room_type = possible_rooms[room_type_key]
		var random_key = self.random.randi_range(0, room_type.size() - 1)
		var room = room_type[random_key]
		# room_type.remove_at(random_key) # TODO: add remove to avoid duplicate rooms
		return room.instantiate()

	func _grow_rooms(rooms, only_bad = false):
		var new_rooms = []
		var room_amount = len(rooms)
		for i_room in range(room_amount):
			var room = rooms[i_room]
			var r = room["room"]
			var children = room["children"]
			var entrances = room["entrances"]
			var tilemap: TileMapLayer = r.get_node("tiles")
			var floor_tile_source = tilemap.tile_set.get_source(FLOOR_TILES)
			var floor_tile_amount = floor_tile_source.get_tiles_count()

			var entrance_indices = []
			while entrance_indices.size() < entrances.size():
				var random_index = self.random.randi_range(0, entrances.size() - 1)
				if random_index not in entrance_indices:
					entrance_indices.append(random_index)

			for i_entrance in entrance_indices:
				var entrance = entrances[i_entrance]
				if not self._rooms_left():
					break

				if (
					entrance["has_connection"]
					or (
						self.random.randi_range(0, 1) == 0
						and not (i_room == room_amount - 1 and new_rooms.is_empty())
					)
				):
					continue

				# TODO: Implement other types of hallways
				var dist := self.random.randi_range(2, 8)
				var room_type = self._get_room_type(only_bad)
				var new_r = self._get_room(room_type)

				var new_tilemap = new_r.get_node("tiles")
				var new_entrances = self._get_room_entrances(new_r)

				var allowed_entrances = []
				for new_entrance in new_entrances:
					if (
						not new_entrance["has_connection"]
						and new_entrance["direction"] == -entrance["direction"]
					):
						allowed_entrances.push_back(new_entrance)

				if not allowed_entrances:
					continue

				# TODO: Try other allowed_entrances when one fails
				# TODO: Maybe rotate Rooms
				# TODO: Add multilevel dungeons
				var new_entrance = allowed_entrances[self.random.randi_range(
					0, len(allowed_entrances) - 1
				)]

				var offset = new_r.to_global(
					new_tilemap.to_global(new_tilemap.map_to_local(new_entrance["start"]))
				)

				var start_entrance = r.to_global(
					tilemap.to_global(tilemap.map_to_local(entrance["start"]))
				)

				var end_entrance = (
					start_entrance
					+ (Vector2(-new_entrance["direction"]) * float(dist) * Vector2(self.tile_size))
				)

				new_r.position = end_entrance - offset

				var new_position_tile = Vector2i(new_r.position / self.tile_size)
				var rect: Rect2i = new_tilemap.get_used_rect()
				rect.position += new_position_tile

				if (
					self._recurse_room_intersections(self.rooms, rect)
					or self._recurse_room_intersections(new_rooms, rect)
				):
					continue

				var new_room = {
					"room": new_r,
					"entrances": new_entrances,
					"children": [],
					#"parent": room,
				}

				var entrance_start = entrance["start"]
				var entrance_end = entrance["end"]
				# hallway
				for tile in [entrance_start, entrance_end]:
					var wall
					if tile == entrance_start:
						wall = entrance_end
					elif tile == entrance_end:
						wall = entrance_start
					for i in range(dist):
						var random_tile = floor_tile_source.get_tile_id(
							self.random.randi_range(0, floor_tile_amount - 1)
						)
						var tile_pos = tile + i * entrance.direction
						if wall:
							var diff = tile - wall
							tilemap.set_cell(
								tile_pos + diff,
								WALL_TILES,
								Vector2i.ZERO,
								self.get_alt_from_direction(diff)
							)
						tilemap.set_cell(tile_pos, FLOOR_TILES, random_tile)

				for tile in [new_entrance["start"], new_entrance["end"]]:
					new_tilemap.set_cell(tile, FLOOR_TILES, Vector2i.ZERO)

				new_entrance["has_connection"] = true
				entrance["has_connection"] = true
				new_r.data = new_room
				children.push_back(new_room)
				new_rooms.push_back(new_room)

			for entrance in entrances:
				if not entrance["has_connection"]:
					for tile in [entrance["start"], entrance["end"]]:
						tilemap.set_cell(
							tile, WALL_TILES, Vector2i.ZERO, tilemap.get_cell_alternative_tile(tile)
						)
		if not new_rooms.is_empty():
			self._grow_rooms(new_rooms)

	func _get_room_entrances(room) -> Array:
		var tilemap: TileMapLayer = room.get_node("tiles")
		var cells = tilemap.get_used_cells()
		var entrances = []

		for cell in cells:
			var tile_data = tilemap.get_cell_tile_data(cell)
			if not tile_data:
				continue
			var entrance_layer_data = tile_data.get_custom_data("entrance_layer")
			if not entrance_layer_data:
				continue

			for neighbour in [Vector2i(1, 0), Vector2i(0, 1)]:
				var neighbour_cell = tilemap.get_cell_tile_data(cell + neighbour)
				if not neighbour_cell:
					continue

				entrance_layer_data = neighbour_cell.get_custom_data("entrance_layer")
				if not entrance_layer_data:
					continue

				var alt = tilemap.get_cell_alternative_tile(cell)
				var direction = self._get_direction_from_alt(alt)

				(
					entrances
					. push_back(
						{
							"start": cell,
							"end": cell + neighbour,
							"direction": direction,
							"has_connection": false,
						}
					)
				)
				break
		return entrances

	static func get_alt_from_direction(direction: Vector2i) -> int:
		var result = 0

		match direction:
			Vector2i(1, 0):
				result |= TileSetAtlasSource.TRANSFORM_TRANSPOSE
			Vector2i(-1, 0):
				result |= (
					TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_TRANSPOSE
				)
			Vector2i(0, -1):
				result |= TileSetAtlasSource.TRANSFORM_FLIP_V
			Vector2i(0, 1):
				result |= 0
		return result

	func _get_direction_from_alt(alt: int) -> Vector2i:
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

		return direction
