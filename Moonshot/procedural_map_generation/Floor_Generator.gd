extends Node2D

#type of room that need to be considered
const ROOM_TYPES : Array = ["Boss", "Reward", "Shop", "Challenge", "Path", "Start"]

#--------------------TWEAK VARIABLES--------------------
const min_Rooms : int = 20
const room_Count_Depth_Multiplier : float = 3.0
var max_Rooms = 100
const room_Count_Variation = 0;

#MAP ARRAY
#initialised to null, will hold a room if there's one there (possibly will hold the index of the room in a list of rooms)
var map = {}
var open_Connections : Dictionary = {}
var room_Count = 0

var rng = RandomNumberGenerator.new()

class Room:
	
	#What type of room it is
	var room_Type
	#What connection requirements it has
	var requirements
	var specific_Room
	
	func _init(type, reqs):
		if ROOM_TYPES.has(type):
			room_Type = type
		else:
			room_Type = "Path"
			push_warning("Room attempted to be created with illegal type")
		requirements = reqs
	
	func set_Specific(specific):
		specific_Room = specific


func _init(depth : int):
	#randomize seed
	rng.randomize()
	
	#decide on a number of rooms for the floor, can be at max the original value
	max_Rooms = min(max_Rooms, room_Count_Depth_Multiplier * depth + min_Rooms + rng.randi_range(0,room_Count_Variation)) as int
	
	#add initial room and connections
	#---------------PLACEHOLDER HACK FOR NOW---------------
	var reqs = [0,1,0,0]
	var pos = Vector2(0, 0)
	add_Room(Room.new("Start", reqs), pos)
	update_Reqs_Around(pos, reqs)

#grow until you can't add any more rooms
func complete_Level():
	var has_Opens:bool = true
	
	while (has_Opens):
		has_Opens = grow()

#grow the level by 1 room
func grow() -> bool:
	#check for open connections
	if open_Connections.size() == 0:
		return false
	
	#pick an open connection at random
	var pos : Vector2 = open_Connections.keys()[0]
	var reqs : Array = open_Connections[pos]
	open_Connections.erase(pos)
	
	#add an appropriate room
	if (room_Count+open_Connections.size() < max_Rooms):
		add_Room(get_Room_With_Requirement(reqs), pos)
	else:
		add_Room(get_Room_With_Requirement(reqs, true), pos)
		
	#update adjacent connections
	update_Reqs_Around(pos, map[pos.x][pos.y].requirements)
	return true


#-------------------Does not check for out of bounds due to hack-------------------
func update_Reqs_Around (pos:Vector2, reqs:Array):
	#----------UP----------
	if (reqs[0] == 1)&&!check_room_exists(pos.x,pos.y-1):
		#already in our list
		if (open_Connections.has(Vector2(pos.x,pos.y-1))):
			open_Connections[Vector2(pos.x,pos.y-1)][2] = 1
		#not already in our list
		else:
			open_Connections[Vector2(pos.x,pos.y-1)] = [0,0,1,0]
			#check up
			if check_room_exists(pos.x, pos.y-2):
				open_Connections[Vector2(pos.x,pos.y-1)][0] = -1
			#check left
			if check_room_exists(pos.x+1, pos.y-1):
				open_Connections[Vector2(pos.x,pos.y-1)][1] = -1
			#check right
			if check_room_exists(pos.x-1, pos.y-1):
				open_Connections[Vector2(pos.x,pos.y-1)][3] = -1
	#----------LEFT----------
	if (reqs[1] == 1)&&!check_room_exists(pos.x+1, pos.y):
		#already in our list
		if (open_Connections.has(Vector2(pos.x+1,pos.y))):
			open_Connections[Vector2(pos.x+1,pos.y)][3] = 1
		#not already in our list
		else:
			open_Connections[Vector2(pos.x+1,pos.y)] = [0,0,0,1]
			#check up
			if check_room_exists(pos.x+1, pos.y-1):
				open_Connections[Vector2(pos.x+1,pos.y)][0] = -1
			#check left
			if check_room_exists(pos.x+2, pos.y):
				open_Connections[Vector2(pos.x+1,pos.y)][1] = -1
			#check down
			if check_room_exists(pos.x+1, pos.y+1):
				open_Connections[Vector2(pos.x+1,pos.y)][2] = -1
	#----------DOWN----------
	if (reqs[2] == 1)&&!check_room_exists(pos.x, pos.y+1):
		#already in our list
		if (open_Connections.has(Vector2(pos.x,pos.y+1))):
			open_Connections[Vector2(pos.x,pos.y+1)][0] = 1
		#not already in our list
		else:
			open_Connections[Vector2(pos.x,pos.y+1)] = [1,0,0,0]
			#check left
			if check_room_exists(pos.x+1, pos.y+1):
				open_Connections[Vector2(pos.x,pos.y+1)][1] = -1
			#check up
			if check_room_exists(pos.x, pos.y+2):
				open_Connections[Vector2(pos.x,pos.y+1)][2] = -1
			#check right
			if check_room_exists(pos.x-1, pos.y+1):
				open_Connections[Vector2(pos.x,pos.y+1)][3] = -1
	#----------RIGHT----------
	if (reqs[3] == 1)&&!check_room_exists(pos.x-1, pos.y):
		#already in our list
		if (open_Connections.has(Vector2(pos.x-1,pos.y))):
			open_Connections[Vector2(pos.x-1,pos.y)][1] = 1
		#not already in our list
		else:
			open_Connections[Vector2(pos.x-1,pos.y)] = [0,1,0,0]
			#check up
			if check_room_exists(pos.x-1, pos.y-1):
				open_Connections[Vector2(pos.x-1,pos.y)][0] = -1
			#check down
			if check_room_exists(pos.x-1, pos.y+1):
				open_Connections[Vector2(pos.x-1,pos.y)][2] = -1
			#check right
			if check_room_exists(pos.x-2, pos.y):
				open_Connections[Vector2(pos.x-1,pos.y)][3] = -1

# Checks if a room exists at (x, y) in the map array
func check_room_exists(x, y):
	if map.has(x):
		if map[x].has(y):
			return true
	return false
	
#adds a room at the requested location and grows the map if needed
func add_Room (room:Room, location:Vector2):
	if not map.has(location.x):
		map[location.x] = {}
	map[location.x][location.y] = room
	room_Count += 1

#placeholder function that either gives a 1x1 room with all connections open or a dead end
func get_Room_With_Requirement (requires, end:bool = false) -> Room:
	var return_Reqs = [0,0,0,0]
	for i in range(4):
		match requires[i]:
			0, 1:
				return_Reqs[i] = 1
	if end:
		return Room.new("Reward", requires)
	else:
		return Room.new("Path", return_Reqs)
