extends Area2D

class_name Spikes

const SPIKE_DAMAGE := 5.0
const SPIKE_COOLDOWN := 1.5

@onready var game := $/root/game
@export var bodies := {}
@export var friendly := false
@export var timer = null
@export var damage := SPIKE_DAMAGE


func _ready() -> void:
	self.bodies = {}
	self.body_entered.connect(self._body_entered)
	self.body_exited.connect(self._body_exited)

func make_friendly(position: Vector2):
	self.position = position
	self.friendly = true
	self.timer = 10.0
	self.modulate = Color.DARK_GREEN
	return self

func _process(delta: float) -> void:
	if self.timer is float:
		self.timer -= delta
		if self.timer <= 0.0:
			self.queue_free()
			
	for body in self.bodies:
		if bodies[body] <= 0.0:
			if self.friendly:
				body.deal_damage(self.damage * self.game.player.attack_factor(0))
			else:
				body.deal_damage(self.damage)
			bodies[body] = SPIKE_COOLDOWN
		bodies[body] -= delta


func _body_entered(body):
	if body not in self.bodies:  # In case deserialized
		if self.friendly and (body is Enemy or body is Boss):
			self.bodies[body] = 0.0
		elif not self.friendly and body is Player:
			self.bodies[body] = 0.0


func _body_exited(body):
	if self.friendly and (body is Enemy or body is Boss):
		self.bodies.erase(body)
	elif not self.friendly and body is Player:
		self.bodies.erase(body)
