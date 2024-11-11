extends Area2D

class_name Item

#enum ItemType {
	#COIN,
	## TODO
#}
#@export var type := ItemType.COIN

@export var collected := false
@export var player_near := false
@onready var player := $/root/game/player

func _ready() -> void:
	self.body_entered.connect(self._body_entered)
	self.body_exited.connect(self._body_exited)

func _process(_delta: float) -> void:
	if self.collected and not $collect_audio.playing:
		self.queue_free()

func _body_entered(body):
	if not self.player_near and not self.collected and body.get_instance_id() == self.player.get_instance_id():
		self.player_near = true
		self._player_area_entered()
		
func _body_exited(body):
	if self.player_near and not self.collected and body.get_instance_id() == self.player.get_instance_id():
		self.player_near = false
		self._player_area_exited()

func collect():
	self.visible = false
	self.collected = true
	$collect_audio.play()
	$collider.set_deferred('disabled', true)

func _player_area_entered():
	pass

func _player_area_exited():
	pass
