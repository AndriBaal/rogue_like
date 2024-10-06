class_name DungeonGeneration

enum DungeonType { GOBLIN }
const TILE_ID := 0


class DungeonOptions:
	var type: DungeonType
	var random_seed: int
	var rooms_left: Dictionary
	var possible_rooms: Dictionary

	func _init(
		type: DungeonType,
		bad_rooms: int,
		good_rooms: int,
		neutral_rooms: int,
		random_seed: int = randi(),
	):
		self.type = type
		self.random_seed = random_seed
		self.rooms_left = {
			"good": good_rooms,
			"bad": bad_rooms,
			"neutral": neutral_rooms,
			"boss": 0,  # TODO: Change to 1
		}

		match self.type:
			DungeonType.GOBLIN:
				self.possible_rooms = {
					"start": load("res://dungeons/goblin_dungeon/start.tscn"),
					"bad":
					[
						load("res://dungeons/goblin_dungeon/enemy1.tscn"),
					],
					"good":
					[
						load("res://dungeons/goblin_dungeon/start.tscn"),
					],
					"neutral":
					[
						load("res://dungeons/goblin_dungeon/start.tscn"),
					],
					"boss": load("res://dungeons/goblin_dungeon/enemy1.tscn")
				}


class Dungeon:
	var options: DungeonOptions
	var rooms_left: Dictionary
	var tile_size: Vector2
	var rooms: Array = []
	var random := RandomNumberGenerator.new()

	func _init(options: DungeonOptions):
		self.options = options
		self.random.seed = options.random_seed
		self.rooms_left = options.rooms_left.duplicate(true)

		var room = options.possible_rooms["start"].instantiate()
		room.start()
		var tilemap: TileMapLayer = room.get_node('tiles')
		self.tile_size = Vector2(tilemap.tile_set.tile_size) * tilemap.scale

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

		var room_type = available_room_types[self.random.randi_range(
			0, available_room_types.size() - 1
		)]  # TODO: Maybe add weighted random

		return room_type

	func _recurse_room_intersections(rooms, rect, rect_offset, rect_cells) -> bool:
		for exsting_room in rooms:
			var existing_tile_map: TileMapLayer = exsting_room.get_node("tiles")
			var existing_rect = existing_tile_map.get_used_rect()
			var existing_offset = Vector2i(exsting_room.position / self.tile_size)
			existing_rect.position += existing_offset
			if rect.intersects(existing_rect):
				var existing_cells = existing_tile_map.get_used_cells()
				for r_cell in rect_cells:
					for er_cell in existing_cells:
						if er_cell + existing_offset == r_cell + rect_offset:
							return true
			if self._recurse_room_intersections(exsting_room.children, rect, rect_offset, rect_cells):
				return true
		return false

	func _get_room(room_type):
		var possible_rooms = self.options.possible_rooms
		var rt = possible_rooms[room_type]
		var random_key = self.random.randi_range(0, rt.size() - 1)
		var room = rt[random_key]
		# room_type.remove_at(random_key) # TODO: add remove to avoid duplicate rooms
		var r = room.instantiate()
		r.start()
		return r

	func _grow_rooms(rooms, only_bad = false):
		var new_rooms = []
		var room_amount = len(rooms)
		for i_room in range(room_amount):
			var room = rooms[i_room]
			var children = room.children
			var entrances = room.entrances
			var tilemap: TileMapLayer = room.get_node("tiles")
			var tilemap_entrances: TileMapLayer = room.get_node("entrances")
			var tile_source = tilemap.tile_set.get_source(TILE_ID)
			var tile_amount = tile_source.get_tiles_count() / 2

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
				var new_room = self._get_room(room_type)

				var new_tilemap = new_room.get_node("tiles")
				var new_entrances = new_room.entrances

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

				var offset = new_room.to_global(
					new_tilemap.to_global(new_tilemap.map_to_local(new_entrance["start"]))
				)

				var start_entrance = room.to_global(
					tilemap.to_global(tilemap.map_to_local(entrance["start"]))
				)

				var end_entrance = (
					start_entrance
					+ (Vector2(-new_entrance["direction"]) * float(dist) * Vector2(self.tile_size))
				)

				new_room.position = end_entrance - offset

				var rect_offset = Vector2i(new_room.position / self.tile_size)
				var rect_cells = new_tilemap.get_used_cells()
				var rect: Rect2i = new_tilemap.get_used_rect()
				rect.position += rect_offset

				if (
					self._recurse_room_intersections(self.rooms, rect, rect_offset, rect_cells)
					or self._recurse_room_intersections(new_rooms, rect, rect_offset, rect_cells)
				):
					continue

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
						var random_tile = Vector2(
							self.random.randi_range(0, tile_amount - 1),
							1
						)
						var tile_pos = tile + i * entrance.direction
						if wall:
							var diff = tile - wall
							var wall_tile = self._get_wall_from_direction(diff)
							tilemap.set_cell(
								tile_pos + diff,
								TILE_ID,
								wall_tile[0],
								wall_tile[1],
							)
						tilemap.set_cell(tile_pos, TILE_ID, random_tile)

				new_entrance["has_connection"] = true
				entrance["has_connection"] = true
				children.push_back(new_room)
				new_rooms.push_back(new_room)
				self.rooms_left[room_type] -= 1

			for entrance in entrances:
				if entrance["has_connection"]:
					for tile in [entrance["start"], entrance["end"]]:
						for neighbour_cell in tilemap_entrances.get_surrounding_cells(tile):
							if tilemap_entrances.get_cell_tile_data(neighbour_cell):
								var neighbour_atlas := tilemap_entrances.get_cell_atlas_coords(neighbour_cell)
								var neighbour_alt := tilemap_entrances.get_cell_alternative_tile(neighbour_cell)
								tilemap.set_cell(neighbour_cell, TILE_ID, neighbour_atlas, neighbour_alt)
					
					for tile in [entrance["start"], entrance["end"]]:
						#var random_tile = Vector2(
							#self.random.randi_range(0, tile_amount - 1),
							#1
						#)
						var t = self._get_door_tile(entrance['direction'])
						tilemap.set_cell(tile, TILE_ID, t[0], t[1])
			tilemap_entrances.queue_free()
		if not new_rooms.is_empty():
			self._grow_rooms(new_rooms)

	func _get_wall_from_direction(direction: Vector2i):
		match direction:
			Vector2i(1, 0):
				return [Vector2i(2, 0), 0]
			Vector2i(-1, 0):
				return [Vector2i(2, 0), TileSetAtlasSource.TRANSFORM_FLIP_H]
			Vector2i(0, -1):
				return [Vector2i(0, 0), 0]
			Vector2i(0, 1):
				return [Vector2i(2, 0), TileSetAtlasSource.TRANSFORM_TRANSPOSE |TileSetAtlasSource.TRANSFORM_FLIP_H]
		
	func _get_door_tile(direction: Vector2i):
		match direction:
			Vector2i(1, 0):
				return [Vector2i(9, 0), 0]
			Vector2i(-1, 0):
				return [Vector2i(9, 0), TileSetAtlasSource.TRANSFORM_FLIP_H]
			Vector2i(0, -1):
				return [Vector2i(7, 0), 0]
			Vector2i(0, 1):
				return [Vector2i(7, 0), 0]
		
	static func _get_direction_from_alt(alt: int) -> Vector2i:
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
