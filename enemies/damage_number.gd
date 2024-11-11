extends Label

class_name DamageNumber

const VELOCITY := 100.0
const LIFE_TIME := 0.75
const OFFSET_RANGE := Vector2(40.0, 40.0)

var alive := 0.0


func start(_position: Vector2, damage: float):
	self.text = str(int(damage))

	var offset = Vector2(
		randf_range(-OFFSET_RANGE.x, OFFSET_RANGE.x),
		randf_range(-OFFSET_RANGE.y, OFFSET_RANGE.y),
	)
	self.position = _position + offset - self.size / 2.0


func _process(delta: float) -> void:
	self.position.y -= delta * VELOCITY
	self.alive += delta
	if self.alive > LIFE_TIME:
		self.queue_free()
