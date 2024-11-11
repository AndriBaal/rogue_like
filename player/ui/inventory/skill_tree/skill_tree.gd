extends Panel

class_name SkillTree


const SKILL_TREE_NODE := preload('res://player/ui/inventory/skill_tree/skill_tree_node.tscn')
const SKILL_TREE_CONNECTION := preload('res://player/ui/inventory/skill_tree/skill_tree_connection.tscn')

@onready var cam := $cam
@onready var game: Game = $/root/game
var last_mouse_pos := Vector2.ZERO
var selected_skill: SkillTreeNode

func _ready() -> void:
	$select/close.pressed.connect(func(): $select.visible = false)
	$select/unlock.pressed.connect(self._unlock)
	$center_camera.pressed.connect(self._center_camera)
	self.visibility_changed.connect(self._visibility_changed)
	
func _visibility_changed():
	if self.visible:
		self._center_camera()
	
func _center_camera():
	var cam: Camera2D = $cam
	var a = self.get_global_rect().size / 2.0
	cam.position = Vector2(a.x, a.y)
	
func _process(_delta: float) -> void:
	var mouse_pos = self.get_local_mouse_position()
	if self.visible and self.get_parent().visible and mouse_pos.x > 0.0 and mouse_pos.y > 0.0:
		if Input.is_action_pressed("primary_attack"):
			self.cam.position += mouse_pos - self.last_mouse_pos
		self.last_mouse_pos = mouse_pos
	
func init_tree(skill_tree, attacks):
	self._recurse_skill_tree(null, skill_tree, attacks)
	
func _recurse_skill_tree(parent, skill_tree, attacks):
	for skill in skill_tree:
		var attack_name = skill['attack_name']
		if 'position' not in skill:
			parent.child_skills.push_back($cam/nodes.get_node(attack_name).get_path())
			return
			
		var attack = attacks[attack_name]
		var node: SkillTreeNode = SKILL_TREE_NODE.instantiate()
		var icon = attack['icon']
		node.name = attack_name
		node.get_node(^'button/background/texture').texture = icon
		node.position = skill['position']
		node.skill = attack
		$cam/nodes.add_child(node)
		if parent:
			parent.child_skills.push_back(node.get_path())
		else:
			node.make_available()
			
		var children = skill['children']
		for child in children:
			var connection := SKILL_TREE_CONNECTION.instantiate()
			connection.points[0] = skill['position']
			connection.points[1] = child['position'] if 'position' in child else $cam/nodes.get_node(child['attack_name'])['position']
			$cam/connections.add_child(connection)
			node.connections.push_back(connection.get_path())
					
		self._recurse_skill_tree(node, children, attacks)
	
func _unlock():
	var player = self.game.player
	$select.visible = false
	self.game.attack_selection.visible = false
	player.skill_tokens -= 1
		
	self.selected_skill.unlock()
	var attack = self.selected_skill.skill
	var slot = null
	
	for s in Player.PlayerAttackSlot.values():
		var type = Player.slot_to_type(s)
		if attack['type'] == type and player.active_attacks[s] == null:
			slot = s
			break
	if slot != null:
		player.assign_attack(slot, attack)
	self.selected_skill = null

func update_skill_token_ui(skill_tokens):
	$skill_tokens/label.text = str(skill_tokens)
