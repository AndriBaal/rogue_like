extends Area2D

class_name Projectile

enum DamageType {
	ICE,
	FIRE,
	PHYSICAL
}

const DESTROY = preload('res://projectiles/destroy.tscn')

@onready var game: Game = $/root/game

@export var speed: float = 650.0
@export var max_age: float = 10.0
@export var damage: float = 4.0
@export var friendly: bool
@export var direction: Vector2
@export var color: Color = Color.WHITE
@export var pierce := 0
@export var rotation_speed := 0.0
@export var damage_type := DamageType.PHYSICAL

func start(friendly: bool, origin: Vector2, target: Vector2) -> void:
	self.friendly = friendly
	self.position = origin
	self.direction = target.normalized()
	self.rotation = atan2(self.direction.y, self.direction.x)

func _ready() -> void:
	self.body_shape_entered.connect(self._on_body_shape_entered)

func _physics_process(delta: float) -> void:
	self.max_age -= delta
	if self.max_age < 0.0:
		self.queue_free()

	self.rotation += self.rotation_speed * delta
	self.position += self.speed * self.direction * delta

func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int):
	var destroy := false
	var inner_collider := local_shape_index == 0
	if self.friendly:
		# Player hits himself
		if body.get_instance_id() == self.game.player.get_instance_id():
			return
			
		# Enemy is hit
		if 'health' in body:
			body.deal_damage(self.damage * self.game.player.attack_factor(self.damage_type))
			if self.pierce > 0:
				self.pierce -= 1
			else:
				destroy = true
		elif inner_collider:
			destroy = true
	else:
		# Player is hit
		if body.get_instance_id() == self.game.player.get_instance_id():
			if not body.deal_damage(self.damage):
				return
		# Other enemy is hit
		elif 'health' in body:
			return
		elif inner_collider:
			destroy = true
		
	if destroy:
		var particle := DESTROY.instantiate()
		var s = $collider.shape.get_rect().size
		var size = min(s.x, s.y)
		particle.rotation = self.rotation - PI / 2
		
		var space_state = self.get_world_2d().direct_space_state

		var result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(self.global_position, self.global_position + 150.0 * self.direction))
		if result:
			particle.position = result.position
		else:
			particle.position = self.global_position + self.direction * self.global_scale * Vector2(size, size)
		particle.self_modulate = self.color
		
		particle.rotation = self.rotation + PI / 2.0
		$/root/game/effects.add_child(particle)
		self.queue_free()
