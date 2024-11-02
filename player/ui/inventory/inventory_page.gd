extends Control

class_name InventoryPage

func _ready() -> void:
	print('asdfasdfasdfasdfasdfasdfa<sdf')
	$navigation.pressed.connect(self._pressed)


func _pressed():
	self.get_parent().make_active(self.name)
