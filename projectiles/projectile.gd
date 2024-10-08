extends Area2D

class_name Projectile

const DESTROY = preload('res://projectiles/destroy.tscn')

@onready var player = $/root/game/player

@export var speed: float = 650.0
@export var max_age: float = 10.0
@export var damage: float = 4.0
@export var friendly: bool
@export var direction: Vector2
@export var color: Color = Color(1 * 2.0, 0.270588  * 2.0, 0, 1  * 2.0)
@export var pierce := 0
@export var rotation_speed := 0.0

func start(friendly: bool, origin: Vector2, target: Vector2) -> void:
	self.friendly = friendly
	self.position = origin
	self.direction = target.normalized()
	self.rotation = atan2(self.direction.y, self.direction.x)

func _ready() -> void:
	self.body_entered.connect(self._on_body_entered)

func _physics_process(delta: float) -> void:
	self.max_age -= delta
	if self.max_age < 0.0:
		self.queue_free()

	self.rotation += self.rotation_speed * delta
	self.position += self.speed * self.direction * delta

func _on_body_entered(body):
	var destroy := false
	if self.friendly:
		# Player hits himself
		if body.get_instance_id() == self.player.get_instance_id():
			return
			
		# Enemy is hit
		if 'health' in body:
			body.deal_damage(self.damage)
			if self.pierce > 0:
				self.pierce -= 1
			else:
				destroy = true
		else:
				destroy = true
	else:
		# Player is hit
		if body.get_instance_id() == self.player.get_instance_id():
			if not body.deal_damage(self.damage):
				return
		# Other enemy is hit
		elif 'health' in body:
			return
		# Wall is hit
		destroy = true
		
	if destroy:
		var d := DESTROY.instantiate()
		var s = $collider.shape.get_rect().size
		var size = min(s.x, s.y)
		d.rotation = self.rotation - PI / 2
		
		var space_state = self.get_world_2d().direct_space_state

		var result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(self.global_position, self.global_position + 150.0 * self.direction))
		if result:
			d.position = result.position
		else:
			d.position = self.global_position + self.direction * self.global_scale * Vector2(size, size)
		d.self_modulate = self.color
		$/root/game/effects.add_child(d)
		self.queue_free()
