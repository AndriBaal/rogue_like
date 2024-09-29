class_name Direction

enum {
	SOUTH,
	SOUTH_EAST,
	EAST,
	NORTH_EAST,
	NORTH,
	NORTH_WEST,
	WEST,
	SOUTH_WEST,
}


# Function to determine the direction based on a Vector2
static func from_vector(val: Vector2) -> int:
	const AMOUNT := 8
	var angle := val.angle()  # Returns angle in radians
	angle = rad_to_deg(angle)  # Convert to degrees
	if angle < 0:
		angle += 360

	var index = int(round(angle / 45.0)) % AMOUNT
	var dir
	match index:
		0:
			dir = Direction.EAST
		1:
			dir = Direction.SOUTH_EAST
		2:
			dir = Direction.SOUTH
		3:
			dir = Direction.SOUTH_WEST
		4:
			dir = Direction.WEST
		5:
			dir = Direction.NORTH_WEST
		6:
			dir = Direction.NORTH
		7:
			dir = Direction.NORTH_EAST
		_:
			dir = Direction.NORTH
	return dir
