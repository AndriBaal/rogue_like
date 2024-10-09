extends ColorRect

class_name SkillTree

enum SkillType {
	ATTACK,
	# TODO
}

const SKILL_TREE_NODE := preload('res://player/ui/inventory/skill_tree/skill_tree_node.tscn')
const SKILL_TREE_CONNECTION := preload('res://player/ui/inventory/skill_tree/skill_tree_connection.tscn')

@onready var cam := $cam
@onready var player: Player = $/root/game/player
var last_mouse_pos := Vector2.ZERO

@export var selected_skill: SkillTreeNode
@export var skill_tree: Array

func _ready() -> void:
	$select/close.pressed.connect(func(): $select.visible = false)
	$select/unlock.pressed.connect(self._unlock)


func _process(delta: float) -> void:
	var mouse_pos = self.get_local_mouse_position()
	if self.visible:
		if Input.is_action_pressed("primary_attack"):
			self.cam.position += mouse_pos - self.last_mouse_pos
		self.last_mouse_pos = mouse_pos
	
func init_tree(skill_tree, attacks, tokens):
	self._update_skill_token_ui(tokens)
	self.skill_tree = skill_tree
	self._recurse_skill_tree(null, skill_tree, attacks)
	
func _recurse_skill_tree(parent, skill_tree, attacks):
	for skill in skill_tree:
		var node = SKILL_TREE_NODE.instantiate()
		var type = skill['type']
		
		var icon
		var s
		match type:
			SkillType.ATTACK:
				s = attacks[skill['attack_name']]
				icon = s['icon']
		node.get_node('button/background/texture').texture = icon
		node.position = skill['position']
		
		var children = skill['children']
		for child in children:
			var connection := SKILL_TREE_CONNECTION.instantiate()
			connection.points[0] = skill['position']
			connection.points[1] = child['position']
			$cam.add_child(connection)
			node.connections.push_back(connection)
					
		node.type = type
		node.skill = s
		if parent:
			parent.child_skills.push_back(node)
		else:
			node.make_available()
		
		$cam.add_child(node)
		self._recurse_skill_tree(node, children, attacks)
	
func _unlock():
	$select.visible = false
	self.selected_skill.unlock()
	match self.selected_skill.type:
		SkillType.ATTACK:
			var attack = self.selected_skill.skill
			var slot = null
			if attack['type'] == Player.AttackType.PRIMARY:
				slot = Player.AttackSlot.PRIMARY_ATTACK
			else:
				slot = Player.AttackSlot.ABILITY1
			self.player.assign_attack(slot, attack)
	self.selected_skill = null
	
func _update_skill_token_ui(amount):
	$skill_tokens/label.text = str(amount)
	
