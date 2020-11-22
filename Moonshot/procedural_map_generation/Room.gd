extends Node
class_name Room

var baddie_builder = load("res://procedural_map_generation/BaddieBuilder.gd")

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

func _init(type, con: Array, level: int, template_name=null):
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
	randomize()
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
		if node.name.begins_with('baddie_spawn_line'):
			baddie_spawn_lines.append(node)
			combined_baddie_spawns.append(node)
		if node.name.begins_with('baddie_spawn_point'):
			baddie_spawn_points.append(node)
			combined_baddie_spawns.append(node)
		elif node.name.begins_with('item_spawn_point'):
			item_spawn_nodes.append(node)
		elif node.name.begins_with('destroyable'):
			loot_destroyable_objects.append(node)
			
			
# Spawns a number of enemies based on the level and size of the room
func spawn_enemies():
	room_size_x = (room_instance.get_node('camera_limit_SE').position.x - room_instance.get_node('camera_limit_NW').position.x)
	room_size_y = (room_instance.get_node('camera_limit_SE').position.y - room_instance.get_node('camera_limit_NW').position.y)
	# Minimum no of enemies must be less than 3
	var min_no_baddies = min(len(baddie_spawn_lines) + len(baddie_spawn_points), 3)
	var max_no_baddies = len(baddie_spawn_points)
	
	var distance
	for line in baddie_spawn_lines:
		var line_points = line.points
		distance = line_points[0].distance_to(line_points[1])
		max_no_baddies += distance / min_baddie_spawn_distance
	max_no_baddies = round(max_no_baddies)
	
	var max_difficult_rating = room_size_x*room_size_y*pow(5, scaling_factor)
	var difficulty_rating = rand_range(0.3, 1)*room_size_x*room_size_y*pow(level_no, scaling_factor)
	var scaled_difficulty_rating = difficulty_rating / max_difficult_rating
	var no_baddies =  round(scaled_difficulty_rating*max_no_baddies)
	print("The number of baddies is: " + str(no_baddies))
	print("The scaled_difficulty_rating is: " + str(scaled_difficulty_rating))
	# Retrieve list of enemies and attributes of enemies (spawn on ground/air/wall + size + difficulty)
	# Keeps track of the location of baddies on the spawn line so that they don't overlap and trigger spawn issues
	var baddie_location_per_spawn_line = {}
	# Decide on the baddie types for each spawn location
	var baddie_type_per_spawn = set_spawn_baddie_type()
	
	# Spawn each baddie
	for i in range(no_baddies):
		# Select a random spawn point/line
		var spawn_place = combined_baddie_spawns[randi()%combined_baddie_spawns.size()]
		var baddie_scene = baddie_type_per_spawn[spawn_place.name]

		# This is here for demonstrative purposes and does nothing 
		var builder: BaddieBuilder = baddie_builder.new(baddie_scene)
		var baddie_instance = builder.patch_attributes({
			builder.attr.GRAVITY: builder.get_attribute(builder.attr.GRAVITY),
			builder.attr.SPEED: builder.get_attribute(builder.attr.SPEED),
		}).build()

		# Create an empty dictionary to keep trackof where baddies have been placed
		if not baddie_location_per_spawn_line.has(spawn_place.name):
			baddie_location_per_spawn_line[spawn_place.name] = {}

		# If it is a spawn point then remove the node from the
		# combined_spawn areas
		# If it is a line then duplicate instance and spawn randomly on the line
		if spawn_place.get_class() == 'Position2D':
			spawn_place.add_child(baddie_instance)
			combined_baddie_spawns.erase(spawn_place)
		else:
			var line_start = spawn_place.points[0]
			var line_end = spawn_place.points[1]
			var point_difference_vector = line_end - line_start
			var rand_step_options = shuffle_list(range(0, round(point_difference_vector.length() / min_baddie_spawn_distance)))
			var chosen_step
			for step in rand_step_options:
				if not baddie_location_per_spawn_line[spawn_place.name].has(step):
					baddie_location_per_spawn_line[spawn_place.name][step] = true
					chosen_step = step
					break
					
			if chosen_step == null:
				continue
					
			var random_point = line_start + chosen_step*(point_difference_vector / min_baddie_spawn_distance)

			print("The line_start is: "+ str(line_start))
			print("The line_end is: " + str(line_end))
			print("The point_difference_vector is: " + str(point_difference_vector))
			print("The random_point is: " + str(random_point))

			spawn_place.add_child(baddie_instance)
			baddie_instance.position = random_point

func set_spawn_baddie_type():
	var spawn_baddie_type = {}
	var selected_baddie
	var baddie_instance
	var new_baddie_instance 
	var baddie_list = get_baddie_list()
	# Decide on the baddies that are allocated for each spawn poinmt
	for spawn_place in combined_baddie_spawns:
		if len(spawn_place.get_children()) == 0:
			selected_baddie = "res://baddies/characters/" + baddie_list[randi()%baddie_list.size()]
		else:
			baddie_instance = spawn_place.get_children()[0]
			# Remove the existing instances
			spawn_place.remove_child(baddie_instance)
			baddie_instance.queue_free()
			
			# Retrieve the location of the enemy scene
			selected_baddie = baddie_instance.script.resource_path
			selected_baddie = selected_baddie.replace('.gd', '.tscn')
		
		# Load the baddie scene
		spawn_baddie_type[spawn_place.name] = load(selected_baddie)
	return spawn_baddie_type
	
# Spawnsmitems at the item locations
func spawn_items():
	# Retrieve the list of items
	
	# Select ones at random
	
	# Spawn them
	pass
	
func get_baddie_list():
	var dir = Directory.new()
	dir.open("res://baddies/characters/")
	dir.list_dir_begin()
	var baddie_filenames = []
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".tscn"):
			baddie_filenames.append(file)	
	return baddie_filenames
	
func shuffle_list(list):
	var shuffled_list = []
	var index_list = range(list.size())
	for i in range(list.size()):
		randomize()
		var x = randi()%index_list.size()
		shuffled_list.append(list[x])
		index_list.remove(x)
		list.remove(x)
	return shuffled_list
