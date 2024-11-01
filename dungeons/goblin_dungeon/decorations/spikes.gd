extends Area2D

class_name Spikes

const SPIKE_DAMAGE := 5.0

func _ready() -> void:
	self.body_entered.connect(self._body_entered)

	
func _body_entered(body):
	if 'health' in body:
		# TODO: Fix standing in spikes
		body.deal_damage(SPIKE_DAMAGE)
