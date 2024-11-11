class_name DungeonGeneration

enum DungeonType { GOBLIN }
const TILE_ID := 0


class DungeonOptions:
	var type: DungeonType
	var random_seed: int
	var rooms_left: Dictionary
	var possible_rooms: Dictionary
	var decorations: Dictionary

	func _init(
		type: DungeonType,
		bad_rooms: int,
		good_rooms: int,
		neutral_rooms: int,
		random_seed: int,
	):
		print("Seed: " + str(random_seed))
		self.type = type
		self.random_seed = random_seed
		self.rooms_left = {
			"good": good_rooms,
			"bad": bad_rooms,
			"neutral": neutral_rooms,
			"boss": 0,
		}

		match self.type:
			DungeonType.GOBLIN:
				self.decorations = {
					"torch": load("res://dungeons/goblin_dungeon/decorations/torch.tscn")
				}
				self.possible_rooms = {
					"start": load("res://dungeons/goblin_dungeon/rooms/start_room.tscn"),
					"bad":
					[
						load("res://dungeons/goblin_dungeon/rooms/enemy_room1.tscn"),
						load("res://dungeons/goblin_dungeon/rooms/enemy_room2.tscn"),
						load("res://dungeons/goblin_dungeon/rooms/enemy_room3.tscn"),
						load("res://dungeons/goblin_dungeon/rooms/enemy_room4.tscn"),
						load("res://dungeons/goblin_dungeon/rooms/enemy_room5.tscn"),
					],
					"good":
					[
						load("res://dungeons/goblin_dungeon/rooms/shop.tscn"),
					],
					"neutral":
					#load("res://dungeons/goblin_dungeon/rooms/start_room.tscn"),
					[],
					"boss": load("res://dungeons/goblin_dungeon/rooms/boss_room.tscn")
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
		var tilemap: TileMapLayer = room.get_node(^"tiles")
		self.tile_size = Vector2(tilemap.tile_set.tile_size) * tilemap.scale

		self.rooms.push_back(room)
		self._grow_rooms(self.rooms, true)
		self._spawn_boss_room(self.rooms, [])
		self._close_rooms(self.rooms)

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
			var existing_tile_map: TileMapLayer = exsting_room.get_node(^"tiles")
			var existing_rect = existing_tile_map.get_used_rect()
			var existing_offset = Vector2i(exsting_room.position / self.tile_size)
			existing_rect.position += existing_offset
			if rect.intersects(existing_rect):
				var existing_cells = existing_tile_map.get_used_cells()
				for r_cell in rect_cells:
					for er_cell in existing_cells:
						if er_cell + existing_offset == r_cell + rect_offset:
							return true
			if self._recurse_room_intersections(
				exsting_room.children, rect, rect_offset, rect_cells
			):
				return true
		return false

	func _get_room(room_type):
		var possible_rooms = self.options.possible_rooms
		var rt = possible_rooms[room_type]
		var room
		if not rt is Array:
			room = rt
		else:
			var random_key = self.random.randi_range(0, rt.size() - 1)
			room = rt[random_key]
			# room_type.remove_at(random_key) # TODO: add remove to avoid duplicate rooms
		var r = room.instantiate()
		r.start()
		return r

	func _random_order(array: Array) -> Array:
		var indices = []
		while indices.size() < array.size():
			var random_index = self.random.randi_range(0, array.size() - 1)
			if random_index not in indices:
				indices.append(random_index)
		return indices

	func _grow_rooms(rooms, only_bad = false):
		var new_rooms = []
		var room_amount = len(rooms)
		for i_room in range(room_amount):
			var room = rooms[i_room]
			var entrances = room.entrances

			for i_entrance in self._random_order(entrances):
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

				var room_type = self._get_room_type(only_bad)
				var new_room = self._get_room(room_type)

				var result = self._connect_rooms(room, entrance, new_room)
				if result:
					new_rooms.push_back(result)
					self.rooms_left[room_type] -= 1

		if new_rooms.is_empty() and self._rooms_left() > 0:
			push_error("Error in dungeon generation, not all rooms used")

		if not new_rooms.is_empty():
			self._grow_rooms(new_rooms)

	func _close_rooms(rooms):
		for room in rooms:
			var children = room.children
			var entrances = room.entrances
			var tilemap: TileMapLayer = room.get_node(^"tiles")
			var tilemap_entrances: TileMapLayer = room.get_node(^"entrances")
			for entrance in entrances:
				if entrance["has_connection"]:
					for tile in [entrance["start"], entrance["end"]]:
						for neighbour_cell in tilemap_entrances.get_surrounding_cells(tile):
							if tilemap_entrances.get_cell_tile_data(neighbour_cell):
								var neighbour_atlas := tilemap_entrances.get_cell_atlas_coords(
									neighbour_cell
								)
								var neighbour_alt := tilemap_entrances.get_cell_alternative_tile(
									neighbour_cell
								)
								tilemap.set_cell(
									neighbour_cell, TILE_ID, neighbour_atlas, neighbour_alt
								)

					for tile in [entrance["start"], entrance["end"]]:
						var t = self._get_door_tile(
							entrance["direction"], tile == entrance["start"]
						)
						tilemap.set_cell(tile, TILE_ID, t[0], t[1])
			tilemap_entrances.clear()

			self._close_rooms(room["children"])

	func _connect_rooms(room, entrance, new_room):
		if entrance["has_connection"]:
			return false

		var children = room.children
		var tilemap: TileMapLayer = room.get_node(^"tiles")
		var tilemap_entrances: TileMapLayer = room.get_node(^"entrances")
		var tile_source = tilemap.tile_set.get_source(TILE_ID)
		var tile_amount = tile_source.get_tiles_count() / 2

		var dist := self.random.randi_range(2, 8)

		var new_tilemap = new_room.get_node(^"tiles")
		var new_entrances = new_room.entrances

		var allowed_entrances = []
		for new_entrance in new_entrances:
			if (
				not new_entrance["has_connection"]
				and new_entrance["direction"] == -entrance["direction"]
			):
				allowed_entrances.push_back(new_entrance)

		if not allowed_entrances:
			return false

		# TODO: Maybe rotate Rooms
		# TODO: Add multilevel dungeons
		var random_entrances = self._random_order(allowed_entrances)
		for i_allowed_entrance in random_entrances:
			var new_entrance = allowed_entrances[i_allowed_entrance]

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

			var new_position = end_entrance - offset
			var rect_offset = Vector2i(new_position / self.tile_size)
			var rect_cells = new_tilemap.get_used_cells()
			var rect: Rect2i = new_tilemap.get_used_rect()
			rect.position += rect_offset

			if self._recurse_room_intersections(self.rooms, rect, rect_offset, rect_cells):
				continue

			new_room.position = new_position
			var entrance_start = entrance["start"]
			var entrance_end = entrance["end"]

			var amount_of_lights = max(ceil(dist / 3.0), 2.0)
			var lights_per = (
				float(dist)
				* self.tile_size
				* Vector2(entrance["direction"])
				/ float(amount_of_lights)
			)
			# hallway
			var f = randi_range(0, 1)
			for tile: Vector2i in [entrance_start, entrance_end]:
				var wall: Vector2i
				if tile == entrance_start:
					wall = entrance_end
				elif tile == entrance_end:
					wall = entrance_start
				var diff := tile - wall
				for i in range(dist):
					var random_tile = Vector2(self.random.randi_range(0, tile_amount - 1), 1)
					var tile_pos = tile + i * entrance.direction

					var wall_tile = self._get_wall_from_direction(diff)
					(
						tilemap
						. set_cell(
							tile_pos + diff,
							TILE_ID,
							wall_tile[0],
							wall_tile[1],
						)
					)
					tilemap.set_cell(tile_pos, TILE_ID, random_tile)

				var a = tilemap.to_global(tilemap.map_to_local(tile))
				for light in range(1, amount_of_lights):
					if (light + f) % 2 == 0:
						continue
					var torch = self.options.decorations["torch"].instantiate()
					var torch_position = a + light * lights_per
					var torch_offset
					var torch_animation
					var flip := false
					match diff:
						Vector2i(1, 0):
							torch_offset = Vector2(self.tile_size.x * 0.35, 0.0)
							torch_animation = "side"
							flip = true
						Vector2i(-1, 0):
							torch_offset = Vector2(-self.tile_size.x * 0.35, 0.0)
							torch_animation = "side"
						Vector2i(0, 1):
							torch_offset = Vector2(0.0, self.tile_size.y * 0.3)
							torch_animation = "bottom"
						Vector2i(0, -1):
							torch_offset = Vector2(0.0, -self.tile_size.y)
							torch_animation = "top"
						_:
							push_error("unreachable")
					torch.play(torch_animation)
					torch.flip_h = flip
					torch.position = torch_position + torch_offset
					room.get_node("decorations").add_child(torch)
				f += 1
			new_entrance["has_connection"] = true
			entrance["has_connection"] = true
			children.push_back(new_room)
			return new_room

	func _find_furthest_room(rooms: Array, furthest, banned: Array):
		for room: Room in rooms:
			var length = room.position.length()

			if (
				room.entrances_left() > 0
				and length > furthest["room"].position.length()
				and room.get_instance_id() not in banned
			):
				furthest["room"] = room
			self._find_furthest_room(room.children, furthest, banned)

	func _spawn_boss_room(rooms: Array, banned: Array):
		var furthest = {"room": rooms[0]}  # Dicto, so we can pass by reference
		self._find_furthest_room(rooms, furthest, banned)
		var room = furthest["room"]
		assert(furthest["room"].entrances_left() > 0)
		var boss_room = self.options.possible_rooms["boss"].instantiate()
		boss_room.start()
		for i_entrance in self._random_order(room.entrances):
			var entrance = room.entrances[i_entrance]
			var result = self._connect_rooms(room, entrance, boss_room)
			if result:
				return
		banned.push_back(room.get_instance_id())
		push_error("Could not spawn boss room!")

	func _get_wall_from_direction(direction: Vector2i):
		match direction:
			Vector2i(1, 0):
				return [Vector2i(2, 0), 0]
			Vector2i(-1, 0):
				return [Vector2i(2, 0), TileSetAtlasSource.TRANSFORM_FLIP_H]
			Vector2i(0, -1):
				return [Vector2i(0, 0), 0]
			Vector2i(0, 1):
				return [
					Vector2i(2, 0),
					TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H
				]

	func _get_door_tile(direction: Vector2i, start):
		match direction:
			Vector2i(1, 0):
				if start:
					return [Vector2i(9, 0), TileSetAtlasSource.TRANSFORM_FLIP_V]
				else:
					return [Vector2i(9, 0), 0]
			Vector2i(-1, 0):
				if start:
					return [
						Vector2i(9, 0),
						TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
					]
				else:
					return [Vector2i(9, 0), TileSetAtlasSource.TRANSFORM_FLIP_H]
			Vector2i(0, -1):
				if start:
					return [Vector2i(7, 0), 0]
				else:
					return [Vector2i(7, 0), TileSetAtlasSource.TRANSFORM_FLIP_H]
			Vector2i(0, 1):
				if start:
					return [Vector2i(7, 0), 0]
				else:
					return [Vector2i(7, 0), TileSetAtlasSource.TRANSFORM_FLIP_H]

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
