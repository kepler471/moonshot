extends Node2D

#type of room that need to be considered
const ROOM_TYPES : Array = ["Boss", "Reward", "Shop", "Challenge", "Path", "Start"]

const min_Rooms : int = 5
const room_Count_Depth_Multiplier : float = 3.0
var max_Rooms = 20
const room_Count_Variation = 0;

#MAP ARRAY
#initialised to null, will hold a room if there's one there (possibly will hold the index of the room in a list of rooms)
var map : Array = []


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
	
	
	

#grow the level by 1 room
func grow():
	pass
	

#placeholder function that either gives a 1x1 room with all connections open or a dead end
func get_Room_With_Requirement (requires, end:bool) -> Room:
	if end:
		return Room.new("Reward", requires)
	else:
		return Room.new("Path", requires)

#resize the map array
func resize_Map (width:int, height:int):
	var newMap = []
	for i in range(width):
		newMap.append([])
		for j in range(height):
			if (i>=map.size())||(j>=map[i].size()):
				newMap[i].append(null)
			else:
				newMap[i].append(map[i][j])
	map = newMap
	
