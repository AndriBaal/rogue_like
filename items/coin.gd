extends Item

class_name Coin

func _on_collect():
	player.add_money(5)
	self.queue_free()
