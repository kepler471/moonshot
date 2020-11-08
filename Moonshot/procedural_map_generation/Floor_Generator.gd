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
var map = [[null]]
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
	var pos = Vector2(max_Rooms + 5, max_Rooms + 5)
	resize_Map(max_Rooms*2 + 10, max_Rooms*2 + 10)
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
	if (reqs[0] == 1)&&!(map[pos.x][pos.y-1]):
		#already in our list
		if (open_Connections.has(Vector2(pos.x,pos.y-1))):
			open_Connections[Vector2(pos.x,pos.y-1)][2] = 1
		#not already in our list
		else:
			open_Connections[Vector2(pos.x,pos.y-1)] = [0,0,1,0]
			#check up
			if (map[pos.x][pos.y-2]):
				open_Connections[Vector2(pos.x,pos.y-1)][0] = -1
			#check left
			if (map[pos.x+1][pos.y-1]):
				open_Connections[Vector2(pos.x,pos.y-1)][1] = -1
			#check right
			if (map[pos.x-1][pos.y-1]):
				open_Connections[Vector2(pos.x,pos.y-1)][3] = -1
	#----------LEFT----------
	if (reqs[1] == 1)&&!(map[pos.x+1][pos.y]):
		#already in our list
		if (open_Connections.has(Vector2(pos.x+1,pos.y))):
			open_Connections[Vector2(pos.x+1,pos.y)][3] = 1
		#not already in our list
		else:
			open_Connections[Vector2(pos.x+1,pos.y)] = [0,0,0,1]
			#check up
			if (map[pos.x+1][pos.y-1]):
				open_Connections[Vector2(pos.x+1,pos.y)][0] = -1
			#check left
			if (map[pos.x+2][pos.y]):
				open_Connections[Vector2(pos.x+1,pos.y)][1] = -1
			#check down
			if (map[pos.x+1][pos.y+1]):
				open_Connections[Vector2(pos.x+1,pos.y)][2] = -1
	#----------DOWN----------
	if (reqs[2] == 1)&&!(map[pos.x][pos.y+1]):
		#already in our list
		if (open_Connections.has(Vector2(pos.x,pos.y+1))):
			open_Connections[Vector2(pos.x,pos.y+1)][0] = 1
		#not already in our list
		else:
			open_Connections[Vector2(pos.x,pos.y+1)] = [1,0,0,0]
			#check left
			if (map[pos.x+1][pos.y+1]):
				open_Connections[Vector2(pos.x,pos.y+1)][1] = -1
			#check up
			if (map[pos.x][pos.y+2]):
				open_Connections[Vector2(pos.x,pos.y+1)][2] = -1
			#check right
			if (map[pos.x-1][pos.y+1]):
				open_Connections[Vector2(pos.x,pos.y+1)][3] = -1
	#----------RIGHT----------
	if (reqs[3] == 1)&&!(map[pos.x-1][pos.y]):
		#already in our list
		if (open_Connections.has(Vector2(pos.x-1,pos.y))):
			open_Connections[Vector2(pos.x-1,pos.y)][1] = 1
		#not already in our list
		else:
			open_Connections[Vector2(pos.x-1,pos.y)] = [0,1,0,0]
			#check up
			if (map[pos.x-1][pos.y-1]):
				open_Connections[Vector2(pos.x-1,pos.y)][0] = -1
			#check down
			if (map[pos.x-1][pos.y+1]):
				open_Connections[Vector2(pos.x-1,pos.y)][2] = -1
			#check right
			if (map[pos.x-2][pos.y]):
				open_Connections[Vector2(pos.x-1,pos.y)][3] = -1

#adds a room at the requested location and grows the map if needed
func add_Room (room:Room, location:Vector2):
	if (location.x < 0)||(location.y < 0)||(location.x >= map.size())||(location.y >= map[location.x].size()):
		resize_Map(max(map.size()-location.x, location.x+1) as int, max(map.front().size()-location.y, location.y+1) as int, Vector2(max(0, 0-location.y), max(0, 0-location.y)))
	if (location.x < 0):
		location.x = 0
	if (location.y < 0):
		location.y = 0
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

#resize the map array
func resize_Map (width:int, height:int, offset:Vector2 = Vector2.ZERO):
	var newMap = []
	for i in range(width):
		newMap.append([])
		for j in range(height):
			if (i<offset.x)||(j<offset.y)||(i>=map.size()+offset.x)||(j>=map[i-offset.x].size()+offset.y):
				newMap[i].append(null)
			else:
				newMap[i].append(map[i-offset.x][j-offset.y])
	map = newMap
	

#removes hacky element and shrinks map back to minimal size
func cleanup():
	var null_Line:bool
	var i:int = 0
	var min_Start:int = map[0].size()
	var max_End:int = 0
	while i < map.size():
		null_Line = true
		for j in range(map[i].size()):
			if map[i][j]:
				null_Line = false
				min_Start = min(min_Start, j)
				max_End = max(max_End, j)
		if null_Line:
			map.remove(i)
		else:
			i += 1
	for k in range(map.size()):
		map[k] = map[k].slice(min_Start, max_End)
