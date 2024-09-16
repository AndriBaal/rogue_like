class_name Utils



class Direction:	
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
	
	var inner: int
	
	func _init(inner: int) -> void:
		self.inner = inner
		
	# Function to determine the direction based on a Vector2
	static func from_vector(val: Vector2) -> Direction:
		const AMOUNT := 8
		var angle := val.angle() # Returns angle in radians
		angle = rad_to_deg(angle) # Convert to degrees
		if angle < 0:
			angle += 360

		var index = int(round(angle / 45.0)) % AMOUNT
		var dir;
		match index:			
			0: dir = Direction.EAST
			1: dir = Direction.SOUTH_EAST
			2: dir = Direction.SOUTH
			3: dir = Direction.SOUTH_WEST
			4: dir = Direction.WEST
			5: dir = Direction.NORTH_WEST
			6: dir = Direction.NORTH
			7: dir = Direction.NORTH_EAST
			_:
				dir = Direction.NORTH
		return Direction.new(dir)
	
	static func south() -> Direction:
		return Direction.new(Direction.SOUTH)
		
	static func south_west() -> Direction:
		return Direction.new(Direction.SOUTH_WEST)
		
	static func west() -> Direction:
		return Direction.new(Direction.WEST)
		
	static func north_west() -> Direction:
		return Direction.new(Direction.NORTH_WEST)
		
	static func north() -> Direction:
		return Direction.new(Direction.NORTH)
		
	static func north_east() -> Direction:
		return Direction.new(Direction.NORTH_EAST)
		
	static func east() -> Direction:
		return Direction.new(Direction.EAST)
		
	static func south_east() -> Direction:
		return Direction.new(Direction.SOUTH_EAST)
	



# Function to merge two directions
#static func merge(s: int, other: int) -> int:
	#match s:
		#Direction.NORTH:
			#match other:
				#DirectionInner.EAST: return DirectionInner.NORTH_EAST
				#DirectionInner.WEST: return DirectionInner.NORTH_WEST
				#_ : return s
		#DirectionInner.EAST:
			#match other:
				#DirectionInner.NORTH: return DirectionInner.NORTH_EAST
				#DirectionInner.SOUTH: return DirectionInner.SOUTH_EAST
				#_ : return s
		#DirectionInner.SOUTH:
			#match other:
				#DirectionInner.EAST: return DirectionInner.SOUTH_EAST
				#DirectionInner.WEST: return DirectionInner.SOUTH_WEST
				#_ : return s
		#DirectionInner.WEST:
			#match other:
				#DirectionInner.NORTH: return DirectionInner.NORTH_WEST
				#DirectionInner.SOUTH: return DirectionInner.SOUTH_WEST
				#_ : return s
		#_:
			#return s
