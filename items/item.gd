extends Area2D

class_name Item

#enum ItemType {
	#COIN,
	## TODO
#}
#@export var type := ItemType.COIN

@export var collected := false
@onready var player := $/root/game/player

func _ready() -> void:
	self.body_entered.connect(self._on_collision)

func _process(delta: float) -> void:
	if self.collected and not $collect_audio.playing:
		self.queue_free()

func _on_collision(body):
	if not self.collected and body.get_instance_id() == self.player.get_instance_id():
		self._on_collect()

func _on_collect():
	self.visible = false
	self.collected = true
	$collect_audio.play()
	$collider.set_deferred('disabled', true)
