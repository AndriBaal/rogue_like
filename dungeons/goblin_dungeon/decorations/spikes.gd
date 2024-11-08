extends Area2D

class_name Spikes

const SPIKE_DAMAGE := 5.0
const SPIKE_COOLDOWN := 1.5

@export var bodies := {}

func _ready() -> void:
	self.body_entered.connect(self._body_entered)
	self.body_exited.connect(self._body_exited)

func _process(delta: float) -> void:
	for body in self.bodies:
		if bodies[body] <= 0.0:
			body.deal_damage(SPIKE_DAMAGE)
			bodies[body] = SPIKE_COOLDOWN
		bodies[body] -= delta
	
func _body_entered(body):
	if 'health' in body and body not in self.bodies: # In case deserialized
		self.bodies[body] = 0.0

func _body_exited(body):
	if 'health' in body:
		self.bodies.erase(body)
