extends Node2D

@onready var target = $/root/game/player
@onready var enemies := $enemies
@onready var tiles := $tiles
@export var data: Dictionary
@export var finished: bool = false
@export var active: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if finished:
		return
		
	var child_count = enemies.get_child_count()
	if child_count == 0:
		if self.active:
			self.active = false
			self._open_room()
		self.finished = true
		
	if not active and not finished:
		var player_pos = self.target.position - self.position
		var player_size = self.target.get_node('collider').shape.get_rect().size * self.target.scale / 2.0
		for entrance in self.data['entrances']:
			var direction = entrance['direction']
			for v in [entrance['start'], entrance['end']]:
				var tile = v - direction
				var player_tile = self.tiles.local_to_map((player_pos - Vector2(-direction) * player_size) / self.tiles.scale)
				if tile == player_tile:
					self.active = true
					self._close_room()
					for enemy in self.enemies.get_children():
						enemy.aggro()
					return
					
func _close_room():
	for entrance in self.data['entrances']:
		if not entrance['has_connection']:
			continue
		var direction = entrance['direction']
		for tile in [entrance["start"], entrance["end"]]:
			self.tiles.set_cell(
				tile, DungeonGeneration.WALL_TILES, Vector2i.ZERO, DungeonGeneration.Dungeon.get_alt_from_direction(direction)
			)

func _open_room():
	for entrance in self.data['entrances']:
		if not entrance['has_connection']:
			continue
		var direction = entrance['direction']
		for tile in [entrance['start'], entrance['end']]:
			self.tiles.set_cell(tile, DungeonGeneration.FLOOR_TILES, Vector2i.ZERO)
			
	
