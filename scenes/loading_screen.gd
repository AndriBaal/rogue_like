extends Node2D

var thread: Thread


func _ready() -> void:
	if OS.get_name() == "Web":
		self._generate_level()
	else:
		thread = Thread.new()
		thread.start(self._generate_level)


func _generate_level():
	var scene
	if Menu.LOAD_SAVE:
		scene = load("user://%s.scn" % Menu.GAME_NAME).instantiate()
		scene.get_node("pause_menu").visible = false
	else:
		scene = load("res://scenes/game.tscn").instantiate()
		var dungeon = DungeonGeneration.Dungeon.new(
			DungeonGeneration.DungeonOptions.new(DungeonGeneration.DungeonType.GOBLIN, 8, 2, 2)
		)
		var player = scene.get_node("player")
		var starting_room = dungeon.rooms[0]["room"]
		player.position = starting_room.global_position

		var room_node = scene.get_node("rooms")
		var cells: Array[Vector2i] = []
		for room in dungeon.rooms:
			self._recurse_add_rooms(cells, room_node, room)
			
		var mini_map = player.get_node('ui/tabs')
		var tilemap = starting_room.get_node('tiles')
		var tile_size = Vector2(tilemap.tile_set.tile_size) * tilemap.scale
		mini_map.init_mini_map(cells, tile_size)
		
	self._on_level_finished.call_deferred(scene)


func _recurse_add_rooms(cells: Array[Vector2i], root, room):
	var r = room["room"]
	var tilemap = r.get_node("tiles")
	var tile_size = Vector2(tilemap.tile_set.tile_size) * tilemap.scale
	var position = Vector2i(r.position / tile_size)
	
	for cell in tilemap.get_used_cells():
		if tilemap.get_cell_source_id(cell) == DungeonGeneration.FLOOR_TILES:
			cells.push_back(cell + position)
			
	root.add_child(r)
	for child in room["children"]:
		self._recurse_add_rooms(cells, root, child)


func _on_level_finished(scene):
	if OS.get_name() != "Web":
		thread.wait_to_finish()

	var tree = get_tree()
	var current_scene = tree.current_scene
	tree.root.remove_child(current_scene)
	current_scene.queue_free()

	tree.root.add_child(scene)
	tree.current_scene = scene
