extends Area2D

@export var speed: float = 400.0
@export var max_age: float = 10.0
@export var damage: float = 4.0
@onready var player = $/root/game/player
var friendly: int;

var velocity: Vector2

func start(friendly: bool, origin: Vector2, target: Vector2) -> void:
	self.friendly = friendly
	self.position = origin
	self.velocity = target.normalized()
	self.rotation = atan2(self.velocity.y, self.velocity.x)

func _ready() -> void:
	self.body_entered.connect(self._on_body_entered)

func _physics_process(delta: float) -> void:
	self.max_age -= delta
	if self.max_age < 0.0:
		self.queue_free()

	self.position += self.speed * self.velocity * delta

func _on_body_entered(body):
	if self.friendly:
		if body.get_instance_id() == self.player.get_instance_id():
			return
			
		if 'health' in body:
			body.deal_damage(self.damage)
	else:
		var parent = body.get_parent()
		if parent.get_instance_id() == self.player.get_instance_id():
			parent.deal_damage(self.damage)
		elif 'health' in body:
			return
	self.queue_free()
