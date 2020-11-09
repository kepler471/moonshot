extends Node2D

const floor_Generator = preload("res://procedural_map_generation/floor_generator.gd")

var node_Types:Dictionary = {}
var template_rooms = []
onready var gen = floor_Generator.new(1)
const distance = 100

func _ready():
	
	node_Types["Boss"] = preload("res://procedural_map_generation/assets/BossNode.tscn")
	node_Types["Challenge"] = preload("res://procedural_map_generation/assets/ChallengeNode.tscn")
	node_Types["Path"] = preload("res://procedural_map_generation/assets/PathNode.tscn")
	node_Types["Reward"] = preload("res://procedural_map_generation/assets/RewardNode.tscn")
	node_Types["Shop"] = preload("res://procedural_map_generation/assets/ShopNode.tscn")
	node_Types["Start"] = preload("res://procedural_map_generation/assets/StartNode.tscn")
	node_Types["Connection"] = preload("res://procedural_map_generation/assets/Connection.tscn")
	
	
	
	gen.complete_Level()
	draw_map()
	load_template_rooms()

func load_template_rooms():
	var rooms = []
	var dir = Directory.new()
	dir.open("res://room_templates")
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.begins_with("room"):
			rooms.append(floor_generator.Room.new("", [], file))
	return rooms
	
	
	
	
func draw_map():
	#needs to be completely rewritten
	var start_pos = Vector2.ZERO
	
	var curr_pos
	var opens = []
	var done = []
	opens.append(start_pos)
	
	while opens.size():
		curr_pos = opens.pop_front()
		add_node_at(curr_pos, gen.map[curr_pos].room_Type)
		var connected = gen.get_Connected_Vectors(curr_pos)
		for c in connected:
			if !done.has(c):
				add_connection_between(curr_pos, c)
				opens.append(c)
		done.append(curr_pos)
	
	

func add_node_at (pos:Vector2, type:String):
	var this_node = node_Types[type].instance()
	this_node.set_position(pos * distance)
	add_child(this_node)
	
func add_connection_between (pos1:Vector2, pos2:Vector2):
	var avg:Vector2 = (pos1 + pos2)/2
	var diff = pos2 - pos1
	var angle
	if(diff.y == 0):
		angle = 0
	elif(diff.x == 0):
		angle = PI/2
	else:
		angle = atan(diff.x/diff.y)
		
	var this_conn = node_Types.Connection.instance()
	this_conn.set_position(avg * distance)
	this_conn.set_rotation(angle)
	add_child(this_conn)
