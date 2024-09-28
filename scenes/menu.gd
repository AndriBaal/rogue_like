extends Node2D

class_name Menu

static var GAME_NAME = null
static var LOAD_SAVE = false

var dir = DirAccess.open("user://")
var files = []

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
	
	self._load_save_files()

func _new_game():
	$title.visible = false
	$load_save.visible = false
	$create_game.visible = true
	
func _quit():
	self.get_tree().quit()
	
func _load_save_files():
	self.files.clear()
	for file in self.dir.get_files():
		self.files.push_back(file.trim_suffix('.scn'))
		
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

func _save_file_selected(index: int):
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
	var r = DirAccess.remove_absolute('user://%s.scn' % game_name)
	$load_save/start.disabled = true
	$load_save/delete.disabled = true
	self._load_save_files()
	
func _start_new_game():
	LOAD_SAVE = false
	GAME_NAME = $create_game/name.text
	self.get_tree().change_scene_to_file("res://scenes/loading_screen.tscn")

func _new_game_name_changed(new_text: String):
	var regex = RegEx.new()
	regex.compile("[^A-Za-z0-9]")
	var result = regex.search(new_text)
	var disabled = result != null or new_text.is_empty()
	for file in self.files:
		if file == new_text:
			disabled = true
	# TODO: Show error in UI
	$create_game/start.disabled = disabled
	
