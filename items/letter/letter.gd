extends Item

class_name Letter

@export_multiline var text: String = "":
	get:
		return $text/label.text
	set(value):
		await ready
		$text/label.text = value


func _player_area_entered():
	$text.visible = true


func _player_area_exited():
	$text.visible = false
