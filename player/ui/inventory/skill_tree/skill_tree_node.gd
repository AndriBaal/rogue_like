extends Control

class_name SkillTreeNode

@onready var game: Game = $/root/game

@export var unlocked := false
@export var available := false
@export var connections := []
@export var child_skills := []
@export var type: SkillTree.SkillType
@export var skill: Dictionary

func _ready() -> void:
	$button.pressed.connect(self._on_click)

func _on_click():
	var skill_tree = $/root/game/player/ui/inventory/skill_tree/content
	for child in self.get_parent().get_children():
		if child.modulate == Color.YELLOW:
			child.modulate = Color.WHITE
	skill_tree.get_node(^'select').visible = true
	skill_tree.get_node(^'select/title').text = '[center]' + self.skill['name'] + '[/center]'
	skill_tree.get_node(^'select/description').text = self.skill['description']
	skill_tree.get_node(^'select/type').text = 'Type: ' + Player.type_to_string(self.skill['type'])
	var unlock = skill_tree.get_node(^'select/unlock')
	if self.unlocked or not self.available or game.player.skill_tokens == 0 or 'unlocked' in self.skill:
		unlock.disabled = true
	else:
		self.modulate = Color.YELLOW
		unlock.disabled = false
	skill_tree.selected_skill = self

func unlock():
	self.skill['unlocked'] = true
	self.modulate = Color.WHITE
	$button/background.self_modulate = Color.GREEN
	for connection in connections:
		connection.default_color = Color.WHITE
	for child in self.child_skills:
		child.make_available()

func make_available():
	self.available = true
	self.modulate = Color.WHITE
