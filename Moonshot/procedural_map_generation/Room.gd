extends Node
class_name Room

var baddie_builder = load("res://procedural_map_generation/BaddieBuilder.gd")
var DifficultyController = load("res://procedural_map_generation/DifficultyController.gd")
var item_drop_chances = load("res://procedural_map_generation/item_drop_chances.gd").new()
#What type of room it is
var room_type
var type_scene
#What connection requirements it has
var connections
var room_template_name
var room_scene
var room_instance
var room_instanced = null
var level_no
var room_size_x
var room_size_y
var difficulty_rating 
var room_difficulty
# Controls how quickly the levels get harder as the levels go up. set between 0.5 - 1
var scaling_factor = 0.75
# Distance between enemy spawns on a line
var min_baddie_spawn_distance = 32

var selected_level_setup
var item_spawn_nodes = []
var baddie_spawn_lines = []
var baddie_spawn_points = []
var combined_baddie_spawns = []
var loot_destroyable_objects =[]

# Type of room that need to be considered
const ROOM_TYPES : Array = ["Boss", "Reward", "Route", "CurrentLocation"]

func _init(type, con: Array, level: int, template_name=null, difficulty=null):
	if ROOM_TYPES.has(type):
		room_type = type
	else:
		room_type = "Route"
		push_warning("Room attempted to be created with illegal type")
	
	level_no = level
	set_type_graphic(type)
	connections = con
	# Name of the room file to associate this room class with
	if template_name:
		room_template_name = template_name
		# Load in the corresponding template
		load_template(room_template_name)
	
	if difficulty:
		room_difficulty = difficulty
		

func set_type_graphic(type):
	# Add the minimap graphics
	match type:
		"Boss":
			type_scene = load("res://procedural_map_generation/assets/BossNode.tscn")
		"Challenge":
			type_scene = load("res://procedural_map_generation/assets/ChallengeNode.tscn")
		"Route":
			type_scene = load("res://procedural_map_generation/assets/PathNode.tscn")
		"Reward":
			type_scene = load("res://procedural_map_generation/assets/RewardNode.tscn")
		"Shop":
			type_scene = load("res://procedural_map_generation/assets/ShopNode.tscn")
		"CurrentLocation":
			type_scene = load("res://procedural_map_generation/assets/CurrentLocation.tscn")
		"Connection":
			type_scene = load("res://procedural_map_generation/assets/Connection.tscn")

func load_template(template_name):
	var filename = "res://room_templates/room_scenes/" + room_type + 'Rooms/' + template_name
	room_scene = load(filename)
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
	randomize()
	room_instance = room_scene.instance()
	var difficulty_controller = DifficultyController.new(level_no)
	room_difficulty = difficulty_controller.random_room_difficulty(room_type)
	room_instance.spawn_things(room_difficulty)
	room_instanced = true
	
