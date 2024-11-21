extends Control

class_name SkillTreeNode

@onready var game: Game = $/root/game

@export var available := false
@export var connections: Array[NodePath] = []
@export var child_skills: Array[NodePath] = []
@export var skill: Dictionary

func _ready() -> void:
	$button.pressed.connect(self._on_click)
	if self.available:
		self.modulate = Color.WHITE

func _on_click():
	var skill_tree = $/root/game/player/ui/inventory/skill_tree/content
	skill_tree.get_node(^'select').visible = true
	skill_tree.get_node(^'select/attack_description').render(self.skill)
	var unlock = skill_tree.get_node(^'select/unlock')
	if not self.available or game.player.skill_tokens == 0 or 'unlocked' in self.skill:
		unlock.disabled = true
	else:
		unlock.disabled = false
	skill_tree.selected_skill = self
	
	
	for child in self.get_parent().get_children():
		if child.modulate == Color.YELLOW:
			child.modulate = Color.WHITE
	if self.available:
		self.modulate = Color.YELLOW

func unlock():
	self.skill['unlocked'] = true
	self.modulate = Color.WHITE
	$button/background.self_modulate = Color.GREEN
	for path in connections:
		var connection = self.get_node(path)
		connection.default_color = Color.WHITE
	for path in self.child_skills:
		var child = self.get_node(path)
		child.make_available()

func make_available():
	self.available = true
	self.modulate = Color.WHITE
