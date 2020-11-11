extends Node2D

var room_dict = {[0,1,0,0]:"BaseRoom2",[0,0,0,1]:"BaseRoom"}
var current_room_node = null

func _ready():
	var first_room = load("res://BaseRoom.tscn")
	current_room_node = first_room.instance()
	#print(current_room_node)
	add_child(current_room_node)
	connect_current_room()


func change_room(exit_key):
	
	var newroom = load("res://" + room_dict[exit_key] + ".tscn")
	
	current_room_node.queue_free()
	current_room_node = newroom.instance()
	call_deferred("add_child",current_room_node)
	connect_current_room()


func connect_current_room():
	print("I am running")
	current_room_node.connect("level_change",self,"change_room")
	
