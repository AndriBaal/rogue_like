extends Node2D

class_name Game


const POP_UP := preload("res://ui/pop_up.tscn")
const SOUND_TRACKS := {
	'relaxed': preload('res://dungeons/goblin_dungeon/sound/menu.mp3'),
	'battle': preload('res://dungeons/goblin_dungeon/sound/battleTrack.mp3'),
}

enum ActiveTrack {
	NONE,
	BATTLE,
	RELAXED
}

@export var active_track = null
@export var last_track_progress :=  {}

@onready var projectiles = $projectiles
@onready var effects = $effects
@onready var ui_effects = $ui_effects
@onready var player: Player = $player
@onready var attack_selection = $player/ui/inventory/character/content/attack_selection


func _ready() -> void:
	$soundtrack.finished.connect(self._track_finished)
	self.play_track('relaxed')
	
func _track_finished():
	$soundtrack.play()

func play_track(track: String):
	var soundtrack = $soundtrack
	if track == self.active_track:
		return
	
	var progress = 0.0
	if self.active_track != null:
		self.last_track_progress[self.active_track] = soundtrack.get_playback_position()
		
	if track in self.last_track_progress:
		progress = self.last_track_progress[track]
		
	soundtrack.stream = SOUND_TRACKS[track]
	soundtrack.play(progress)
	self.active_track = track

func is_valid_position(p: Vector2, ignore_entities = false) -> bool:
	var rooms = $rooms.get_children()
	var valid = false
	for room: Room in rooms:
		if not room.finished:
			if room.active:
				valid = false
			else:
				continue
		
		var tilemap: TileMapLayer = room.get_node('tiles')
		var local = tilemap.local_to_map(tilemap.to_local(p))
		var tile_data = tilemap.get_cell_tile_data(local)
		if tile_data != null:
			if tile_data.get_collision_polygons_count(0) == 0:
				valid = true
		
		if room.active:
			break
			
	if valid and not ignore_entities:
		var space_state = get_world_2d().direct_space_state
		var params = PhysicsPointQueryParameters2D.new()
		params.position = p
		params.collision_mask = 0b0001_1010
		var result = space_state.intersect_point(params)
		
		if len(result):
			valid = false
	
	return valid

func spawn_pop_up(title, description):
	var pop_up = POP_UP.instantiate()
	pop_up.start(title, description)
	$player/ui.add_child(pop_up)

func spawn_projectile(projectile, origin: Vector2, target: Vector2, friendly: bool = false) -> void:
	projectile.start(friendly, origin, target)
	self.projectiles.add_child(projectile)
	projectile.set_owner($/root/game)
	
