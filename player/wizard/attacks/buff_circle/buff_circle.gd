extends Area2D

class_name BuffCircle


@onready var game: Game = $/root/game
@export var player_inside := false

func _ready() -> void:
	self.body_entered.connect(self._body_entered)
	self.body_exited.connect(self._body_exited)

func start(p: Vector2) -> BuffCircle:
	self.position = p
	return self
	
func _process(_delta: float) -> void:
	if player_inside:
		game.player.effects['buff_circle'] = {
			'duration': 1.0,
			'attack': 1.4
		}

func _body_entered(body):
	if body is Player:
		player_inside = true
		
func _body_exited(body):
	if body is Player:
		player_inside = false
