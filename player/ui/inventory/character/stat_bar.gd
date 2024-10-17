extends HBoxContainer

class_name StatBar

@onready var player = $/root/game/player

@export var property: String
@export var label: String


func _ready() -> void:
	$label.text = self.label + ':'
	$increase.pressed.connect(self._increase)
	$decrease.pressed.connect(self._decrease)
	%close.pressed.connect(self._close_attack_selection)

func _decrease():
	if self.player[self.property] <= 1:
		return
	player.level_up_tokens += 1
	self.player.decrease_stat(self.property)
	self._update_ui()

func _increase():
	if player.level_up_tokens > 0:
		player.level_up_tokens -= 1
		self.player.increase_stat(self.property)
		self._update_ui()

func _update_ui():
	$level.text = str(self.player[self.property])

func _close_attack_selection():
	pass
