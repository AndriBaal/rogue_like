extends Button

class_name AttackSelection

@export var slot: Player.PlayerAttackSlot
@export var attack: Dictionary

@onready var game: Game = $/root/game

func _ready() -> void:
	self.pressed.connect(self._select_attack)
	$attack_description.render(self.attack)
	
func _process(delta: float) -> void:
	$attack_description.visible = self.is_hovered()
	
func _select_attack():
	var selection = game.attack_selection
	selection.visible = false
	
	var attacks = game.player.active_attacks
	for active_slot in attacks:
		var active_attack = attacks[active_slot]
		if active_attack and active_attack == self.attack:
			game.player.assign_attack(active_slot, null)
	
	game.player.assign_attack(self.slot, self.attack)
