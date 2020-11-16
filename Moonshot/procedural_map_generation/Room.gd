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

var selected_level_setup
var item_spawn_nodes = []
var baddie_spawn_areas = []
var loot_destroyable_objects =[]

# Type of room that need to be considered
const ROOM_TYPES : Array = ["Boss", "Reward", "Shop", "Challenge", "Path", "CurrentLocation"]

func _init(type, con: Array, level: int, template_name=null):
	if ROOM_TYPES.has(type):
		room_type = type
	else:
		room_type = "Path"
		push_warning("Room attempted to be created with illegal type")
	
	level_no = level
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
	var setup_room_bool = select_level_setup()
	if setup_room_bool:
		get_spawn_nodes()
		spawn_enemies()
		spawn_items()
	room_instanced = true
	
# Function to select a random level setup and remove the others from the room
func select_level_setup():
	# Retrieve the different level setups
	var level_setups_node = room_instance.get_node('level_setups')
	if level_setups_node == null:
		return false
	var level_setups = level_setups_node.get_children()
	selected_level_setup = level_setups[randi()%level_setups.size()]
	# Delete all the level setups not nee
	for level_setup in level_setups:
		if not level_setup.name == selected_level_setup.name:
			level_setup.queue_free()
	return true

# Fetches all the spawn nodes and stores them in the class for easier access
func get_spawn_nodes():
	var spawn_nodes = selected_level_setup.get_children()
	for node in spawn_nodes:
		if node.name.begins_with('baddie_spawn_zone'):
			baddie_spawn_areas.append(node)
		elif node.name.begins_with('item_spawn_point'):
			item_spawn_nodes.append(node)
		elif node.name.begins_with('loot_destroyable'):
			loot_destroyable_objects.append(node)
			
			
# Spawns a number of enemies based on the level and size of the room
func spawn_enemies():
	room_size_x = (room_instance.get_node('camera_limit_SE').position.x - room_instance.get_node('camera_limit_NW').position.x)
	room_size_y = (room_instance.get_node('camera_limit_SE').position.y - room_instance.get_node('camera_limit_NW').position.y)
	var difficulty_rating = room_size_x*room_size_y*(pow(level_no, scaling_factor))
	var no_enemies = rand_range(0.3, 1) * difficulty_rating / 60000
	# Retrieve list of enemies and attributes of enemies (spawn on ground/air/wall + size + difficulty)
	var baddie_list = get_baddie_list()
	
	# Select one type of enemie to include in the map
	var selected_baddie = baddie_list[randi()%baddie_list.size()]
	var baddie_scene = load("res://baddies/" + selected_baddie)
	
	# Spawn the enemies, initally randomly and then later on walls/floor etc.
	var level_setup_nodes = selected_level_setup.get_children()
	
	# Split the enemies across all the spawn areas
	for i in range(no_enemies):
		# Select a spawn area at random
		var spawn_area = baddie_spawn_areas[randi()%baddie_spawn_areas.size()].polygon
		var max_x = -100000
		var min_x = 100000
		var max_y = -100000
		var min_y = 100000
		# Get the limits of the spawn area (max & min x, y across all points)
		for point in spawn_area:
			if point.x > max_x:
				max_x = point.x
			elif point.x < min_x:
				min_x = point.x
			if point.y > max_y:
				max_y = point.y
			elif point.y < min_y:
				min_y = point.y
				
		# Select a random position within the spawn area 
		var rand_x = rand_range(min_x,max_x)
		var rand_y = rand_range(min_y, max_y)
		
		# Spawn baddie
		var new_baddie = baddie_scene.instance()
		new_baddie.position.x = rand_x
		new_baddie.position.y = rand_y
		room_instance.add_child(new_baddie)
		
# Spawnsmitems at the item locations
func spawn_items():
	# Retrieve the list of items
	
	# Select ones at random
	
	# Spawn them
	pass
	
func get_baddie_list():
	var dir = Directory.new()
	dir.open("res://baddies/")
	dir.list_dir_begin()
	var baddie_filenames = []
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".tscn"):
			baddie_filenames.append(file)	
	return baddie_filenames
