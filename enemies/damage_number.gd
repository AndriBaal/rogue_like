extends Label

class_name DamageNumber

const VELOCITY := 100.0
const LIFE_TIME := 0.75

var alive := 0.0

func start(position: Vector2, damage: float):
	self.text = str(int(damage))
	self.position = position

func _process(delta: float) -> void:
	self.position.y -= delta * VELOCITY
	self.alive += delta
	if self.alive > LIFE_TIME:
		self.queue_free()
		
