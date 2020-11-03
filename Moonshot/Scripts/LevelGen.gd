extends Node2D

class Room:
	
	const ROOM_TYPES : Array = ["Shop", "Boss", "Reward", "Challenge", "Path"]
	
	var room_Type
	
	func _init(type):
		if ROOM_TYPES.has(type):
			room_Type = type
		else:
			room_Type = "Path"
			push_warning("Room attempted to be created with illegal type")
	
	
	
#set limits to the random generation to ensure some regularity of levels
var min_Max_By_Room_Type : Dictionary = {
	"Shop" : [0,1],
	"Boss" : [1,1],
	"Reward" : [1,1],
	"Challenge" : [0,2]
}
var min_Max_Total_Rooms : Array = [4, 10]
var min_Travel_To_Boss : int = 3

#size of a 1x1 room
var grid_Size : int = 100

func init_Floor ():
	pass


func grow () -> bool:
	return false


func _ready():
	var rm = Room.new("Shop")
	print(rm.room_Type)
