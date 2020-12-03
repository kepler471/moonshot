extends Node2D

class_name floor_generator

var Room = load("res://procedural_map_generation/Room.gd")
#--------------------TWEAK VARIABLES--------------------
const rooms_per_level : int = 9
const extra_rooms_per_level = 3
const max_rooms_per_level = 40
var max_rooms
# Spawn room indexed by level
var starting_room = {
	1: 'spawn_level_1.tscn',
	2: 'spawn_level_2.tscn',
	3: 'spawn_level_3.tscn',
	4: 'spawn_level_4.tscn',
	5: 'spawn_level_5.tscn'}
var floor_level



# 'map' will store the final dictionary of rooms, indexed by a vector
var map = {}
# 'open_Connections' will store locations where a new room can be placed
var open_Connections : Dictionary = {}
# 'template_rooms' will store all the room_templates in the 'room_templates' folder
var template_rooms = []
# 'room_locations' will store the places where rooms need to be placed in 'map'
var room_locations = {}
# Will store if there is a boss room that has been created or not to ensure there is only one
var boss_room_created = false
var directions = {"LEFT": Vector2.LEFT, "UP": Vector2.DOWN, "RIGHT": Vector2.RIGHT, "DOWN": Vector2.UP}
var rng = RandomNumberGenerator.new()
var available_room_indexes = {}

func _init(level : int):
	# Randomize seed
	rng.randomize()
	floor_level = level
	# Decide on a number of rooms for the floor, can be at max the original value
	max_rooms = min(rooms_per_level + extra_rooms_per_level*level, max_rooms_per_level)
	
	# Add initial room & surround with rooms so that the start is always the same
	var pos = Vector2.ZERO
	room_locations[pos] = true
	for vec in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		room_locations[pos+vec] = true
		add_new_room_locations(pos+vec)

# Main algorithm function 
func complete_Level():		
	template_rooms = load_template_rooms()
	# Insert all the indexes for rooms so that there are no duplicate rooms per floor
	for room_type in template_rooms.keys():
		available_room_indexes[room_type] = range(0, template_rooms[room_type].size())
		
	while len(room_locations.keys()) < max_rooms:
		grow()
	
	fill_with_rooms()

	
# Load all room templates into a list of Rooms
func load_template_rooms():
	var room_dict = {"Boss": [], "Reward": [], "Route": [], "FinalBoss": []}
	for key in room_dict.keys():
		var dir = Directory.new()
		var folder_name = "res://room_templates/room_scenes/" + key + "Rooms"
		dir.open(folder_name)
		dir.list_dir_begin()

		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif file.begins_with("room"):
				room_dict[key].append(Room.new(key, [], 0, file))
	return room_dict


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
	add_Room(Room.new("Route", [], floor_level, starting_room[floor_level % 6]), Vector2(0, 0))

	
	# For all other rooms, identify the adjacent rooms i.e. connection requirements
	# Then find a tempalte room with those requirementsand add to the map dictionary
	for pos in room_locations.keys():
		# Already set the starting room
		if pos == 	Vector2(0, 0):
			continue
		var reqs = get_room_requirements(pos)
		add_Room(get_Room_With_Requirement(reqs), pos)
	
	if not boss_room_created:
		add_boss_room()

# Searches for a place where a single connected room can be added
func add_boss_room():
	var pos : Vector2 = open_Connections.keys()[rng.randi_range(0,open_Connections.size()-1)]
	var room_reqs = get_room_requirements(pos)
	# For the final boss, only look for the UP connection
	if floor_level == 5:
		while room_reqs != ['UP']:
			pos = open_Connections.keys()[rng.randi_range(0,open_Connections.size()-1)]
			room_reqs = get_room_requirements(pos)
	else:
		while len(room_reqs) != 1:
			pos = open_Connections.keys()[rng.randi_range(0,open_Connections.size()-1)]
			room_reqs = get_room_requirements(pos)
	add_Room(get_Room_With_Requirement(room_reqs), pos)
	boss_room_created = true
	
		
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

	
# If a room with only one connection then select either BOSS, 
	# REWARD or SHOP
	var room_type
	if len(requires) == 1:
				# Check to see if a final boss room can be inserted
		if floor_level == 5 && arrays_match(requires, ['UP']):
			room_type = "FinalBoss"
			boss_room_created = true
		elif not boss_room_created && floor_level != 5:		
			room_type = "Boss"
			boss_room_created = true
		else:
			room_type = "Reward"
	else:
		room_type = "Route"
			
	while true:
		rng.randomize()
		# If no available rooms of that typs then reset the index list
		if available_room_indexes[room_type].size() == 0:
			available_room_indexes[room_type] = range(0, template_rooms[room_type].size())
		# Fetch a random room index from the list
		var rand_index = available_room_indexes[room_type][randi()%available_room_indexes[room_type].size()]
		var rand_room = template_rooms[room_type][rand_index]
		if rand_room.can_make_connections(requires):
			# Copy the room_template
			new_room = Room.new(room_type, [], floor_level, rand_room.get_template_name())
			new_room.set_connections(requires)
			available_room_indexes[room_type].remove(rand_index)
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
