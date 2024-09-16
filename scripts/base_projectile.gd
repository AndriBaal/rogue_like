extends Area2D

@export var speed: float = 400.0
@export var max_age: float = 10.0
var velocity: Vector2

func start(origin: Vector2, target: Vector2) -> void:
	self.position = origin
	self.velocity = target.normalized()
	
func _ready() -> void:
	self.connect("body_entered", self._on_body_entered)
	
func _physics_process(delta: float) -> void:
	self.max_age -= delta
	if self.max_age < 0.0:
		self.queue_free()
		
	self.position += self.speed * self.velocity * delta

func _on_body_entered(body):
	self.queue_free()
