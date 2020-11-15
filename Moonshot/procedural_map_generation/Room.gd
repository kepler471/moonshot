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
var level_no
var room_size_x
var room_size_y
var difficulty_rating 
# Controls how quickly the levels get harder as the levels go up. set between 0.5 - 1
var scaling_factor = 0.75
# Type of room that need to be considered
const ROOM_TYPES : Array = ["Boss", "Reward", "Shop", "Challenge", "Path", "CurrentLocation"]

func _init(type, con: Array, level_no: int, template_name=null):
	if ROOM_TYPES.has(type):
		room_type = type
	else:
		room_type = "Path"
		push_warning("Room attempted to be created with illegal type")
	
	level_no = level_no
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
	select_level_setup()
	spawn_enemies()
	spawn_items()
	room_instanced = true
	
# Function to select a random level setup and remove the others from the room
func select_level_setup():
	# Retrieve the different level setups
	
	# Selecet a random one
	
	# Delete other level setups
	pass
	
# Spawns a number of enemies based on the level and size of the room
func spawn_enemies():
	#room_size_x = (room_instance.camera_limit_SE.position.x - room_instance.camera_limit_NW.position.x)
	#room_size_y = (room_instance.camera_limit_SE.position.y - room_instance.camera_limit_NW.position.y)
	#var difficulty_rating = room_size_x*room_size_y*(level_no^scaling_factor)
	pass
	
	# Retrieve list of enemies and attributes of enemies (spawn on ground/air/wall + size + difficulty)
	
	# Select some types of enemies to include in the map
	
	# Function to calculate the no. enemies of each type depending on their individual 
	# difficulty rating and the level difficulty rating
	
	# Spawn the enemies, initally randomly and then later on walls/floor etc.
	
# Spawnsmitems at the item locations
func spawn_items():
	# Retrieve the list of items
	
	# Select ones at random
	
	# Spawn them
	pass
	
