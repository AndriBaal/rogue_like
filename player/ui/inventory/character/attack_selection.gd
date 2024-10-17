extends Button

class_name AttackSelection

@export var slot: Player.PlayerAttackSlot
@export var attack: Dictionary

@onready var game: Game = $/root/game

func _ready() -> void:
	self.pressed.connect(self._select_attack)
	
func _select_attack():
	var selection = game.attack_selection
	selection.visible = false
	
	for active_attack in game.player.active_attacks.values():
		if active_attack == self.attack:
			game.player.assign_attack(self.slot, null)
	
	game.player.assign_attack(self.slot, self.attack)
