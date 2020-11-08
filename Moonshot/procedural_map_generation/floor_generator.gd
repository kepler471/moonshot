extends Node2D

class_name floor_generator

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
	var connections
	var specific_Room
	
	func _init(type, con):
		if ROOM_TYPES.has(type):
			room_Type = type
		else:
			room_Type = "Path"
			push_warning("Room attempted to be created with illegal type")
		connections = con
	
	func set_Specific(specific):
		specific_Room = specific


func _init(depth : int):
	#randomize seed
	rng.randomize()
	
	#decide on a number of rooms for the floor, can be at max the original value
	max_Rooms = min(max_Rooms, room_Count_Depth_Multiplier * depth + min_Rooms + rng.randi_range(0,room_Count_Variation)) as int
	
	#add initial room and connections
	var reqs = [0,1,0,0]
	var pos = Vector2.ZERO
	add_Room(Room.new("Start", reqs), pos)
	update_Reqs_Around(pos, map[pos].connections)

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
	var pos : Vector2 = open_Connections.keys()[rng.randi_range(0,open_Connections.size()-1)]
	var reqs : Array = open_Connections[pos]
	var _o = open_Connections.erase(pos)
	
	#add an appropriate room
	if (room_Count+open_Connections.size() < max_Rooms):
		add_Room(get_Room_With_Requirement(reqs), pos)
	else:
		add_Room(get_Room_With_Requirement(reqs, true), pos)
		
	#update adjacent connections
	update_Reqs_Around(pos, map[pos].connections)
	return true


func update_Reqs_Around (pos:Vector2, reqs:Array):
	#----------UP----------
	var check_pos = pos + Vector2.UP
	if (reqs[0] == 1)&&!check_room_exists(check_pos):
		#already in our list
		if (open_Connections.has(check_pos)):
			open_Connections[check_pos][2] = 1
		#not already in our list
		else:
			open_Connections[check_pos] = [0,0,1,0]
			#check up
			if check_room_exists(check_pos + Vector2.UP):
				open_Connections[check_pos][0] = -1
			#check left
			if check_room_exists(check_pos + Vector2.RIGHT):
				open_Connections[check_pos][1] = -1
			#check right
			if check_room_exists(check_pos + Vector2.LEFT):
				open_Connections[check_pos][3] = -1
	#----------RIGHT----------
	check_pos = pos + Vector2.RIGHT
	if (reqs[1] == 1)&&!check_room_exists(check_pos):
		#already in our list
		if (open_Connections.has(check_pos)):
			open_Connections[check_pos][3] = 1
		#not already in our list
		else:
			open_Connections[check_pos] = [0,0,0,1]
			#check up
			if check_room_exists(check_pos + Vector2.UP):
				open_Connections[check_pos][0] = -1
			#check right
			if check_room_exists(check_pos + Vector2.RIGHT):
				open_Connections[check_pos][1] = -1
			#check down
			if check_room_exists(check_pos + Vector2.DOWN):
				open_Connections[check_pos][2] = -1
	#----------DOWN----------
	check_pos = pos + Vector2.DOWN
	if (reqs[2] == 1)&&!check_room_exists(check_pos):
		#already in our list
		if (open_Connections.has(check_pos)):
			open_Connections[check_pos][0] = 1
		#not already in our list
		else:
			open_Connections[check_pos] = [1,0,0,0]
			#check left
			if check_room_exists(check_pos + Vector2.RIGHT):
				open_Connections[check_pos][1] = -1
			#check down
			if check_room_exists(check_pos + Vector2.DOWN):
				open_Connections[check_pos][2] = -1
			#check right
			if check_room_exists(check_pos + Vector2.LEFT):
				open_Connections[check_pos][3] = -1
	#----------LEFT----------
	check_pos = pos + Vector2.LEFT
	if (reqs[3] == 1)&&!check_room_exists(check_pos):
		#already in our list
		if (open_Connections.has(check_pos)):
			open_Connections[check_pos][1] = 1
		#not already in our list
		else:
			open_Connections[check_pos] = [0,1,0,0]
			#check up
			if check_room_exists(check_pos + Vector2.UP):
				open_Connections[check_pos][0] = -1
			#check down
			if check_room_exists(check_pos + Vector2.DOWN):
				open_Connections[check_pos][2] = -1
			#check left
			if check_room_exists(check_pos + Vector2.LEFT):
				open_Connections[check_pos][3] = -1

# Checks if a room exists at (x, y) in the map array
func check_room_exists(pos:Vector2):
	if map.has(pos):
			return true
	return false
	
#adds a room at the requested location and grows the map if needed
func add_Room (room:Room, location:Vector2):
	map[location] = room
	room_Count += 1

#placeholder function that either gives a 1x1 room with all connections open or a dead end
func get_Room_With_Requirement (requires:Array, end:bool = false) -> Room:
	var return_Reqs = [0,0,0,0]
	#add required connections
	for i in range(4):
		match requires[i]:
			1:
				return_Reqs[i] = 1
	
	#add more connections if we're not near the end
	if !end:
		var extra_Connections
		if open_Connections.size() == 0:
			extra_Connections = rng.randi_range(1, min(max_Rooms-room_Count,4-requires.count(1)))
		else:
			extra_Connections = rng.randi_range(0, min(max_Rooms-room_Count,4-requires.count(1)))
		for _i in range(extra_Connections):
			var x = rng.randi_range(0,3-return_Reqs.count(1))
			for a in range(4):
				if return_Reqs[a] == 0:
					if x == 0:
						return_Reqs[a] = 1
					else:
						x -= 1
			
	if return_Reqs.count(1) == 1:
		var type = ROOM_TYPES[rng.randi_range(0,3)]
		return Room.new(type, return_Reqs)
	else:
		return Room.new("Path", return_Reqs)

func get_Connected_Vectors (position:Vector2) -> Array:
	var ret = []
	if map.has(position):
		var cons = map[position].connections
		#---UP---
		if cons[0]:
			ret.append(position+Vector2.UP)
		if cons[1]:
			ret.append(position+Vector2.RIGHT)
		if cons[2]:
			ret.append(position+Vector2.DOWN)
		if cons[3]:
			ret.append(position+Vector2.LEFT)
	return ret
