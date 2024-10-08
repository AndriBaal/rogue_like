extends Control

class_name SkillTreeNode

@export var unlocked := false
@export var available := false
@export var connections := []
@export var child_skills := []
@export var type: SkillTree.SkillType
@export var skill: Dictionary


func unlock():
	self.modulate = Color.WHITE
	$button/background.self_modulate = Color.GREEN
	for connection in connections:
		connection.default_color = Color.WHITE
	for child in self.child_skills:
		child.make_available()
		
func make_available():
	self.available = true
	self.modulate = Color.WHITE
