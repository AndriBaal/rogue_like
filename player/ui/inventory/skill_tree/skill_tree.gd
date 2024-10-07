extends ColorRect

class_name SkillTree

enum SkillType {
	ATTACK,
	# TODO
}

@onready var cam := $cam

static var SKILL_TREE_NODE := preload('res://player/ui/inventory/skill_tree/skill_tree_node.tscn')
static var SKILL_TREE_CONNECTION := preload('res://player/ui/inventory/skill_tree/skill_tree_connection.tscn')
var last_mouse_pos := Vector2.ZERO

@export var selected_skill: String
@export var skill_tree: Array

func _ready() -> void:
	$select/close.pressed.connect(func(): $select.visible = false)
	$select/buy.pressed.connect(self._buy)


func _process(delta: float) -> void:
	var mouse_pos = self.get_local_mouse_position()
	if self.visible:
		if Input.is_action_pressed("primary_attack"):
			self.cam.position += mouse_pos - self.last_mouse_pos
		self.last_mouse_pos = mouse_pos
	
func init_tree(skill_tree, attacks):
	self.skill_tree = skill_tree
	for skill in skill_tree:
		var node = SKILL_TREE_NODE.instantiate()
		var type = skill['type']
		
		var icon
		var name
		var description
		match type:
			SkillType.ATTACK:
				var attack = attacks[skill['attack_name']]
				icon = attack['icon']
				name = '[center]' + attack['name'] + '[/center]'
				description = attack['description']
		node.get_node('button/background/texture').texture = icon
		node.position = skill['position']
		
		var on_click = func():
			$select.visible = true
			$select/title.text = name
			$select/description.text = description
			selected_skill = name
			
		node.get_node('button').pressed.connect(on_click)
		self.cam.add_child(node)
		
		
		var children = skill['children']
		for child in children:
			var connection := SKILL_TREE_CONNECTION.instantiate()
			connection.points[0] = skill['position']
			connection.points[1] = child['position']
			self.cam.add_child(connection)
			
		self.init_tree(children, attacks)
	
func _buy():
	$select.visible = false
	
