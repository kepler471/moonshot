extends Node
class_name Room

#What type of room it is
var room_type
var type_scene
#What connection requirements it has
var connections
var room_template_name
var room_scene
var room_instance
var room_instanced = null


# Type of room that need to be considered
const ROOM_TYPES : Array = ["Boss", "Reward", "Shop", "Challenge", "Path", "CurrentLocation"]

func _init(type, con: Array, template_name=null):
	if ROOM_TYPES.has(type):
		room_type = type
	else:
		room_type = "Path"
		push_warning("Room attempted to be created with illegal type")
		
	set_type_graphic(type)
	connections = con
	# Name of the room file to associate this room class with
	if template_name:
		room_template_name = template_name
		# Load in the corresponding template
		load_template(room_template_name)

func set_type_graphic(type):
	# Add the minimap graphics
	match type:
		"Boss":
			type_scene = preload("res://procedural_map_generation/assets/BossNode.tscn")
		"Challenge":
			type_scene = preload("res://procedural_map_generation/assets/ChallengeNode.tscn")
		"Path":
			type_scene = preload("res://procedural_map_generation/assets/PathNode.tscn")
		"Reward":
			type_scene = preload("res://procedural_map_generation/assets/RewardNode.tscn")
		"Shop":
			type_scene = preload("res://procedural_map_generation/assets/ShopNode.tscn")
		"CurrentLocation":
			type_scene = preload("res://procedural_map_generation/assets/CurrentLocation.tscn")
		"Connection":
			type_scene = preload("res://procedural_map_generation/assets/Connection.tscn")

func load_template(template_name):
	room_scene = load("res://room_templates/room_scenes/"+ template_name)
	room_instance = room_scene.instance()
	var room_child_nodes = []
	for child in room_instance.get_children():
		room_child_nodes.append(child.name)
	
	# Recreate the connections variable for the template
	connections = []
	var directions = {"LEFT": Vector2.LEFT, "UP": Vector2.UP, "RIGHT": Vector2.RIGHT, "DOWN": Vector2.DOWN}
	for exit_location in directions.keys():
		# Check what doors there are and build connections appropriatly
		if "Exit_" + exit_location in room_child_nodes:
			# Confusing, as UP is [0, -1] in godot land
			connections.append(exit_location)

			
	room_instance.queue_free()
	room_child_nodes.clear()


func set_room_type(type):
	room_type = type
	set_type_graphic(type)
	
func get_room_type():
	return room_type
	
func get_type_scene():
	return type_scene
	
func get_template_name():
	return room_template_name
	
func get_scene():
	return room_scene
	
func get_instance():
	return room_instance

func is_instanced():
	return room_instanced
	
func instance():
	room_instance = room_scene.instance()
	room_instanced = true
	
