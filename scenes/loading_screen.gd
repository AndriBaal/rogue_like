extends Node2D

var thread: Thread


func _ready() -> void:
	thread = Thread.new()
	thread.start(self._generate_level)


func _generate_level():
	var scene = load("res://scenes/game.tscn").instantiate()
	var dungeon = DungeonGeneration.Dungeon.new(
		DungeonGeneration.DungeonOptions.new(DungeonGeneration.DungeonType.GOBLIN, 8, 2, 2)
	)
	var room_node = scene.get_node("rooms")
	for room in dungeon.rooms:
		self._recurse_add_rooms(room_node, room)
	self._on_level_finished.call_deferred(scene)


func _recurse_add_rooms(root, room):
	root.add_child(room["room"])
	for child in room["children"]:
		self._recurse_add_rooms(root, child)


func _on_level_finished(scene):
	thread.wait_to_finish()

	var tree = get_tree()
	var current_scene = get_tree().current_scene
	tree.root.remove_child(current_scene)
	current_scene.queue_free()

	tree.root.add_child(scene)
	tree.current_scene = scene
