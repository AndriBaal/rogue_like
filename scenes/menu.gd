extends Control

class_name Menu

static var GAME_NAME = null
static var LOAD_SAVE := false
static var SEED := 0

var dir := DirAccess.open("user://")
var files := []
var name_regex := RegEx.new()
var valid_seed := ""


func _ready():
	$title/new_game.pressed.connect(self._new_game)
	$title/load_game.pressed.connect(self._load_game)
	$title/quit.pressed.connect(self._quit)

	$load_save/back.pressed.connect(self._back)
	$load_save/start.pressed.connect(self._start_game)
	$load_save/delete.pressed.connect(self._delete_game)
	$load_save/save_files.item_selected.connect(self._save_file_selected)

	$create_game/back.pressed.connect(self._back)
	$create_game/start.pressed.connect(self._start_new_game)
	$create_game/name.text_changed.connect(self._new_game_name_changed)
	$create_game/seed.text_changed.connect(self._new_game_seed_changed)

	self.name_regex.compile("[^A-Za-z0-9]")
	self._load_save_files()
	self._new_game_name_changed($create_game/name.text)
	self.get_tree().paused = false


func _new_game():
	$title.visible = false
	$load_save.visible = false
	$create_game.visible = true


func _quit():
	self.get_tree().quit()


func _load_save_files():
	self.files.clear()
	for file in self.dir.get_files():
		self.files.push_back(file.trim_suffix(".scn"))

	var save_files = $load_save/save_files
	save_files.clear()
	for file in self.files:
		save_files.add_item(file)


func _back():
	$load_save/save_files.deselect_all()
	$create_game/name.clear()
	$title.visible = true
	$load_save.visible = false
	$create_game.visible = false


func _load_game():
	$title.visible = false
	$load_save.visible = true


func _save_file_selected(_index: int):
	$load_save/start.disabled = false
	$load_save/delete.disabled = false


func _start_game():
	LOAD_SAVE = true
	GAME_NAME = self._selected_save_file()
	self.get_tree().change_scene_to_file("res://scenes/loading_screen.tscn")


func _selected_save_file():
	var save_files = $load_save/save_files
	return save_files.get_item_text(save_files.get_selected_items()[0])


func _delete_game():
	var game_name = self._selected_save_file()
	var result = DirAccess.remove_absolute("user://%s.scn" % game_name)
	if result != OK:
		push_error("Error while deleting save file: %s" % game_name)
	$load_save/start.disabled = true
	$load_save/delete.disabled = true
	self._load_save_files()


func _start_new_game():
	LOAD_SAVE = false
	GAME_NAME = $create_game/name.text
	var seed = $create_game/seed
	if not seed.text.is_empty() and seed.text.is_valid_int():
		SEED = int(seed.text)
	else:
		SEED = randi()
	self.get_tree().change_scene_to_file("res://scenes/loading_screen.tscn")


func _new_game_name_changed(new_text: String):
	var result = self.name_regex.search(new_text)
	var error = null
	if new_text.is_empty():
		error = "Please enter a name!"
	if result != null:
		error = "Name contains invalid characters!"
	for file in self.files:
		if file == new_text:
			error = "A save with this name already exists!"

	var error_label = $create_game/error
	if error:
		error_label.text = error

	var valid = false if error == null else true
	error_label.visible = valid
	$create_game/start.disabled = valid


func _new_game_seed_changed(new_text: String):
	var seed = $create_game/seed
	if not seed.text.is_valid_int() and not new_text.is_empty():
		seed.text = self.valid_seed
		seed.caret_column = len(new_text)
	else:
		self.valid_seed = new_text
