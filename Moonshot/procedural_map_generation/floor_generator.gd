extends Node2D

class_name floor_generator

var Room = load("res://procedural_map_generation/Room.gd")
#--------------------TWEAK VARIABLES--------------------
const min_rooms : int = 20
const room_Count_Depth_Multiplier : float = 3.0
var max_rooms = 100
const room_Count_Variation = 0;
var starting_room = 'room_base.tscn'

# 'map' will store the final dictionary of rooms, indexed by a vector
var map = {}
# 'open_Connections' will store locations where a new room can be placed
var open_Connections : Dictionary = {}
# 'template_rooms' will store all the room_templates in the 'room_templates' folder
var template_rooms = []
# 'room_locations' will store the places where rooms need to be placed in 'map'
var room_locations = {}

var directions = {"LEFT": Vector2.LEFT, "UP": Vector2.DOWN, "RIGHT": Vector2.RIGHT, "DOWN": Vector2.UP}
var rng = RandomNumberGenerator.new()


func _init(depth : int):
	# Randomize seed
	rng.randomize()
	
	# Decide on a number of rooms for the floor, can be at max the original value
	max_rooms = min(max_rooms, room_Count_Depth_Multiplier * depth + min_rooms + rng.randi_range(0,room_Count_Variation)) as int
	
	# Add initial room & surround with rooms so that the start is always the same
	var pos = Vector2.ZERO
	room_locations[pos] = true
	for vec in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		room_locations[pos+vec] = true
		add_new_room_locations(pos+vec)

# Main algorithm function 
func complete_Level():		
	template_rooms = load_template_rooms()
	while len(room_locations.keys()) < max_rooms:
		grow()
	
	fill_with_rooms()

	
# Load all room templates into a list of Rooms
func load_template_rooms():
	var room_list = []
	var dir = Directory.new()
	dir.open("res://room_templates")
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.begins_with("room"):
			room_list.append(Room.new("", [], file))
	return room_list


# Grow the room_locations list by placing one room next to an exsisting room
func grow():
	# Pick an open connection at random
	var pos : Vector2 = open_Connections.keys()[rng.randi_range(0,open_Connections.size()-1)]
	var _o = open_Connections.erase(pos)
	
	# Add a room at the open connection
	room_locations[pos] = true
		
	# Identify new places where rooms can now be placed
	add_new_room_locations(pos)


# Given the 2-D grid of room locations, assign a room template and room type
func fill_with_rooms():
	# Ensure that the starting room is always the same
	add_Room(Room.new("Path", [], starting_room), Vector2(0, 0))
	
	# For all other rooms, identify the adjacent rooms i.e. connection requirements
	# Then find a tempalte room with those requirementsand add to the map dictionary
	for pos in room_locations.keys():
		# Already set the starting room
		if pos == 	Vector2(0, 0):
			continue
		var reqs = get_room_requirements(pos)
		add_Room(get_Room_With_Requirement(reqs), pos)

# For a given room in the room_locations map, identify all the connecting rooms
func get_room_requirements(pos):
	var reqs = []
	for key in directions.keys():
		if room_locations.has(pos+directions[key]):
			reqs.append(key)

	return reqs
			
# Identifies any new potential locations to place rooms in the room_locations map
func add_new_room_locations(pos:Vector2):
	for vec in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		if not room_locations.has(pos+vec):
			open_Connections[pos+vec] = true
			
# Checks if a room exists at (x, y) in the map array
func check_room_exists(pos:Vector2):
	if map.has(pos):
			return true
	return false
	
# Adds a room at the requested location
func add_Room (room, location:Vector2):
	map[location] = room

# Keep fetching a random template room to see if it matches the connection requirements
# For now only look for fully connected rooms or end rooms
func get_Room_With_Requirement (requires:Array, end:bool = false):	
	var new_room = null
	# Flip up and down requirements
	for i in len(requires):
		if requires[i] == "UP":
			requires[i] = "DOWN"
		elif requires[i] == "DOWN":
			requires[i] = "UP"

	
	while true:
		var rand_room = template_rooms[randi()%template_rooms.size()]
		if arrays_match(rand_room.connections, requires):
			# Copy the room_template
			new_room = Room.new("", [], rand_room.get_template_name())
			# If a room with only one connection then select either BOSS, 
			# REWARD or SHOP
			if len(requires) == 1:
				var type = Room.ROOM_TYPES[rng.randi_range(0,3)]
				new_room.set_room_type(type)
			else:
				new_room.set_room_type("Path")
			break
	return new_room


func get_Connected_Vectors (position:Vector2) -> Array:
	var ret = []
	for key in directions.keys():
		if map.has(position + directions[key]):
			ret.append(position + directions[key])
	return ret

# Checks if two arrays have the same items, irrespective of order
func arrays_match(array1, array2):
	if array1.size() != array2.size(): return false
	for item in array1:
		if !array2.has(item): return false
		if array1.count(item) != array2.count(item): return false
	return true
