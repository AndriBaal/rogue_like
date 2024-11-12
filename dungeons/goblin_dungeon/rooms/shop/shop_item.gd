@tool

extends Area2D

enum ShopItemType {
	Potion,
	SkillToken,
	LevelUpToken
}

@onready var game: Game = $/root/game
@export var type: ShopItemType
@export var texture: Texture2D:
	get():
		return $sprite.texture
	set(value):
		$sprite.texture = value

@export var price := 10:
	get():
		return price
	set(value):
		price = value
		$price.text = str(value)
@export var player_near := false:
	set(value):
		player_near = value
		$buy_hint.visible = value

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	self.body_entered.connect(self._player_entered)
	self.body_exited.connect(self._player_exited)
		
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if self.player_near and Input.is_action_just_pressed('interact'):
			var player = game.player
			if player.money >= self.price:
				player.money -= self.price
				player.get_node('buy_audio').play()
				match self.type:
					ShopItemType.Potion:
						player.refill_potion(1)
					ShopItemType.LevelUpToken:
						player.level_up_tokens += 1
					ShopItemType.SkillToken:
						player.skill_tokens += 1
			
func _player_entered(body):
	if body is Player:
		self.player_near = true

func _player_exited(body):
	if body is Player:
		self.player_near = false
		
