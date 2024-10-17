extends ColorRect

func _ready() -> void:
	%close.pressed.connect(self._close_attack_selection)

func update_level_up_token_ui(level_up_tokens):
	$level_up_tokens/label.text = str(level_up_tokens)

func _close_attack_selection():
	%attack_selection.visible = false
