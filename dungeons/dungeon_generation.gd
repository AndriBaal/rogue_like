class_name DungeonGeneration

enum DungeonType { GOBLIN }


class DungeonOptions:
	var type: DungeonType
	var random_seed: int
	var size: Vector2i
	var rooms_left: Dictionary
	var min_room_spacing: int
	var max_bruteforce_tries: int
	var possible_rooms: Dictionary

	func _init(
		type: DungeonType,
		good_rooms: int,
		bad_rooms: int,
		neutral_rooms: int,
		size: Vector2i = Vector2i(100, 100),
		min_room_spacing: int = 1,
		random_seed: int = randi(),
	):
		self.type = type
		self.random_seed = random_seed
		self.size = size
		self.rooms_left = {
			"good": good_rooms,
			"bad": bad_rooms,
			"neutral": neutral_rooms,
			"boss": 0,  # TODO: Change to 1
		}
		self.min_room_spacing = min_room_spacing

		match self.type:
			DungeonType.GOBLIN:
				self.possible_rooms = {
					"start": load("res://dungeons/goblin_dungeon/enemy_room1.tscn"),
					"bad":
					[
						load("res://dungeons/goblin_dungeon/enemy_room1.tscn"),
					],
					"good":
					[
						load("res://dungeons/goblin_dungeon/enemy_room1.tscn"),
					],
					"neutral_rooms":
					[
						load("res://dungeons/goblin_dungeon/enemy_room1.tscn"),
					],
					"boss": load("res://dungeons/goblin_dungeon/enemy_room1.tscn")
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
		var rect := tilemap.get_used_rect()
		var size = self.options.size - rect.size
		var pos = Vector2(
			self.random.randi_range(-size.x, size.x),
			self.random.randi_range(-size.y, size.y),
		)

		self.tile_size = Vector2(tilemap.tile_set.tile_size) * tilemap.scale
		room.position = pos * self.tile_size

		room = {
			"room": room,
			"entrances": self._get_room_entrances(room),
			"children": [],
			"parent": null,
		}
		self.rooms.push_back(room)
		self._grow_rooms(self.rooms, true)

	func _rooms_left() -> int:
		var sum = 0
		for v in self.rooms_left:
			sum += self.rooms_left[v]
		return sum

	func _get_room(only_bad):
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

		var possible_rooms = self.options.possible_rooms
		var room_type_key = available_room_types[self.random.randi_range(
			0, available_room_types.size() - 1
		)]  # TODO: Maybe add weighted random
		self.rooms_left[room_type_key] -= 1

		var room_type = possible_rooms[room_type_key]
		var random_key = self.random.randi_range(0, room_type.size() - 1)
		var room = room_type[random_key]
		#room_type.remove_at(random_key) # TODO: ad remove
		return room.instantiate()

	func _grow_rooms(rooms, only_bad = false):
		const WALL_TILES = 1
		const FLOOR_TILES = 0

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

			for entrance in entrances:
				if not self._rooms_left():
					break

				if (
					entrance["has_connection"]
					or (
						self.random.randi_range(0, 1) == 2
						and not (i_room == room_amount - 1 and new_rooms.is_empty())
					)
				):
					continue

				var dist := self.random.randi_range(2, 12)
				var new_r = self._get_room(only_bad)
				var new_tilemap = new_r.get_node("tiles")
				var new_entrances = self._get_room_entrances(new_r)
				var new_room = {
					"room": new_r,
					"entrances": new_entrances,
					"children": [],
					"parent": room,
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
						var floor_tile = self.random.randi_range(0, floor_tile_amount - 1)
						var tile_pos = tile + i * entrance.direction
						if wall:
							var diff = tile - wall
							tilemap.set_cell(
								tile_pos + diff,
								WALL_TILES,
								Vector2i.ZERO,
								self._get_alt_from_direction(diff)
							)
						tilemap.set_cell(tile_pos, FLOOR_TILES, random_tile)

				var allowed_entrances = []
				for new_entrance in new_entrances:
					if (
						not new_entrance["has_connection"]
						and new_entrance["direction"] == -entrance["direction"]
					):
						allowed_entrances.push_back(new_entrance)
				if allowed_entrances:
					var new_entrance = allowed_entrances[self.random.randi_range(
						0, len(allowed_entrances) - 1
					)]
					var start_entrance = r.to_global(
						tilemap.to_global(tilemap.map_to_local(entrance["start"]))
					)
					var end_entrance = (
						start_entrance
						+ (
							Vector2(-new_entrance["direction"])
							* float(dist)
							* Vector2(self.tile_size)
						)
					)
					var offset = new_r.to_global(
						new_tilemap.to_global(new_tilemap.map_to_local(new_entrance["start"]))
					)
					new_r.position = end_entrance - offset

					for tile in [new_entrance["start"], new_entrance["end"]]:
						new_tilemap.set_cell(tile, FLOOR_TILES, Vector2i.ZERO)

					new_entrance["has_connection"] = true
					entrance["has_connection"] = true
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
		var rect = tilemap.get_used_rect()
		var entrances = []

		for x in range(rect.position.x, rect.end.x):
			for y in range(rect.position.y, rect.end.y):
				var coords = Vector2i(x, y)
				var tile_data = tilemap.get_cell_tile_data(coords)
				if not tile_data:
					continue
				var entrance_layer_data = tile_data.get_custom_data("entrance_layer")
				if not entrance_layer_data:
					continue

				for neighbour in [Vector2i(1, 0), Vector2i(0, 1)]:
					var cell = tilemap.get_cell_tile_data(coords + neighbour)
					if not cell:
						continue

					entrance_layer_data = cell.get_custom_data("entrance_layer")
					if not entrance_layer_data:
						continue

					var alt = tilemap.get_cell_alternative_tile(coords)
					var direction = self._get_direction_from_alt(alt)

					(
						entrances
						. push_back(
							{
								"start": coords,
								"end": coords + neighbour,
								"direction": direction,
								"has_connection": false,
							}
						)
					)
					break
		return entrances

	func _get_alt_from_direction(direction: Vector2i) -> int:
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
