extends Area2D

class_name Projectile

@onready var player = $/root/game/player

@export var speed: float = 650.0
@export var max_age: float = 10.0
@export var damage: float = 4.0
@export var friendly: bool
@export var velocity: Vector2
@export var pierce := 0

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
			if self.pierce > 0:
				self.pierce -= 1
			else:
				self.queue_free()
		# Wall is hit
		self.queue_free()
	else:
		# Player is hit
		if body.get_instance_id() == self.player.get_instance_id():
			if not body.deal_damage(self.damage):
				return
		# Other enemy is hit
		elif 'health' in body:
			return
		# Wall is hit
		self.queue_free()
