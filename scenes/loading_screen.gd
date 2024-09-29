extends Node2D

var thread: Thread


func _ready() -> void:
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
		player.position = dungeon.rooms[0]["room"].global_position

		var room_node = scene.get_node("rooms")
		for room in dungeon.rooms:
			self._recurse_add_rooms(room_node, room)
	self._on_level_finished.call_deferred(scene)


func _recurse_add_rooms(root, room):
	root.add_child(room["room"])
	#room["room"].owner = root.get_parent()
	for child in room["children"]:
		self._recurse_add_rooms(root, child)


func _on_level_finished(scene):
	thread.wait_to_finish()

	var tree = get_tree()
	var current_scene = tree.current_scene
	tree.root.remove_child(current_scene)
	current_scene.queue_free()

	tree.root.add_child(scene)
	tree.current_scene = scene
