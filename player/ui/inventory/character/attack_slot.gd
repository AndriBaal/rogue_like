extends Button

class_name AttackSlot

@onready var game: Game = $/root/game
@export var label: String:
	get:
		return $label.text
	set(value):
		$label.text = value

const ATTACK_SELECTION = preload("res://player/ui/inventory/character/attack_selection.tscn")

func _ready() -> void:
	self.pressed.connect(self._change_attack)

func _change_attack():
	var selection = game.attack_selection
	selection.visible = true
	
	var box := selection.get_node(^'scroll/box')
	
	var attacks = game.player.attacks
	for child in box.get_children():
		child.queue_free()
	for attack_name in attacks:
		var attack = attacks[attack_name]
		if 'unlocked' not in attack:
			continue
		var slot = Player.string_to_slot(self.name)
		var type = Player.slot_to_type(slot)
		if type != attack['type']:
			continue
		var select = ATTACK_SELECTION.instantiate()
		select.icon = attack['icon']
		select.slot = slot
		select.attack = attack
		box.add_child(select)
