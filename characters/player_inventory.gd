extends TabContainer

@onready var map_camera := $Map/cam
@onready var map_player := $Map/cam/player
@onready var player := $/root/game/player
@export var tile_size: Vector2
var last_mouse_pos := Vector2.ZERO

const SCALE := 10.0

func _ready() -> void:
	pass
	
func init_mini_map(cells, tile_size):
	var last_mouse_pos := false
	var optimized_cells := self._optimize_cells(cells)
	self.tile_size = tile_size
	for cell in optimized_cells:
		var color_rect := ColorRect.new()
		color_rect.size = cell.size * SCALE
		color_rect.position = cell.position * SCALE
		$Map/cam.add_child(color_rect)
		$Map/cam.move_child(color_rect, 0)
	
# Function to group adjacent cells into rectangles
func _optimize_cells(cells: Array[Vector2i]) -> Array[Rect2]:
	var all_cells_in_row = func(start_x: int, end_x: int, y: int, cells: Array[Vector2i], processed_cells: Array[Vector2i]) -> bool:
		for x in range(start_x, end_x + 1):
			if Vector2i(x, y) not in cells or Vector2i(x, y) in processed_cells:
				return false
		return true
	var rects: Array[Rect2] = []
	var processed_cells: Array[Vector2i] = []

	# Sort cells first by y and then by x to make grouping easier
	cells.sort()

	for cell in cells:
		if cell in processed_cells:
			continue
		
		# Start forming a rectangle from the current cell
		var start = cell
		var width = 1
		var height = 1
		
		# Try to extend the rectangle horizontally (rightwards)
		while Vector2i(start.x + width, start.y) in cells and Vector2i(start.x + width, start.y) not in processed_cells:
			width += 1

		# Try to extend the rectangle vertically (downwards) while all cells in the row are filled
		while all_cells_in_row.call(start.x, start.x + width - 1, start.y + height, cells, processed_cells):
			height += 1

		# Mark all cells within the formed rectangle as processed
		for x in range(start.x, start.x + width):
			for y in range(start.y, start.y + height):
				processed_cells.append(Vector2i(x, y))

		# Add the rectangle to the list
		rects.append(Rect2(Vector2(start), Vector2(width, height)))

	return rects


func _process(delta: float) -> void:
	var mouse_pos = $Map.get_local_mouse_position()
	if self.current_tab == 3 and Input.is_action_pressed("primary_attack"):
		self.map_camera.position += mouse_pos - self.last_mouse_pos
	if $Map.visible:
		self.map_player.position = self.player.position / self.tile_size * SCALE - self.map_player.size / 2.0
		self.last_mouse_pos = mouse_pos
