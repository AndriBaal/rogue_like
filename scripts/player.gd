extends Node2D

@onready var body = $player_body
@onready var cam = $player_body/main_camera2d

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_pressed("zoom_in"):
		cam.zoom += Vector2.ONE * delta
		
	if Input.is_action_pressed("zoom_out"):
		cam.zoom -= Vector2.ONE * delta

func _physics_process(delta: float) -> void:
	const speed: float = 600.0;
	var velocity = Vector2.ZERO;
	velocity.x += Input.get_action_strength("move_right");
	velocity.x -= Input.get_action_strength("move_left");
	velocity.y -= Input.get_action_strength("move_up");
	velocity.y += Input.get_action_strength("move_down");
	body.velocity = velocity * speed;
	var res = body.move_and_slide()
