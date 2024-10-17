extends ColorRect


func update_level_up_token_ui(level_up_tokens):
	$level_up_tokens/label.text = str(level_up_tokens)
	%close.pressed.connect(self._close_attack_selection)

func _close_attack_selection():
	%attack_selection.visible = false
