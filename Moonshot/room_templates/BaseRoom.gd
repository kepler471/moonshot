extends Node2D

signal indicate_room_change(exit_key, entrance)

const MAIN_GAME : bool = false


var baddie_builder = load("res://procedural_map_generation/BaddieBuilder.gd")
var DifficultyController = load("res://procedural_map_generation/DifficultyController.gd")
var item_drop_chances = load("res://procedural_map_generation/item_drop_chances.gd").new()

var selected_level_setup
export var testing_room_difficulty = 1
var scaling_factor = 0.75
# Distance between enemy spawns on a line
var min_baddie_spawn_distance = 32

var item_spawn_nodes = []
var baddie_spawn_lines = []
var baddie_spawn_points = []
var combined_baddie_spawns = []

func _ready():
	if get_tree().get_current_scene().MAIN_GAME == false:
		self.add_child(Utils.Player)
		Utils.Player.position = self.get_node("testing_player_spawn").position
		Utils.Player.state_machine.transition_to("Move/Spawn", {"room": true})
		self.setup_player_camera()
		spawn_things(testing_room_difficulty)
		
	
func spawn_things(room_difficulty):
	randomize()
	var setup_room_bool = select_level_setup()
	var difficulty_controller : DifficultyController = DifficultyController.new(room_difficulty)
	if setup_room_bool:
		get_spawn_nodes()
		spawn_baddies(difficulty_controller, room_difficulty)
		spawn_items()
	
# Function to select a random level setup and remove the others from the room
func select_level_setup():
	# Retrieve the different level setups
	var level_setups_node = find_node('level_setups')
	if level_setups_node == null:
		return false
	var level_setups = level_setups_node.get_children()
	if !level_setups:
		return false
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

			
			
# Spawns a number of enemies based on the level and size of the room
func spawn_baddies(difficulty_controller: DifficultyController, room_difficulty):
	# Minimum no of enemies must be less than 3
	var min_no_baddies = min(len(baddie_spawn_lines) + len(baddie_spawn_points), 3)
	var max_no_baddies = len(baddie_spawn_points)
	
	var distance
	for line in baddie_spawn_lines:
		line.visible = false
		var line_points = line.points
		distance = line_points[0].distance_to(line_points[1])
		max_no_baddies += distance / min_baddie_spawn_distance
	max_no_baddies = round(max_no_baddies)
	
		
	var no_baddies = difficulty_controller.get_no_baddies_in_room(room_difficulty, max_no_baddies, min_no_baddies)
	
	# Retrieve list of enemies and attributes of enemies (spawn on ground/air/wall + size + difficulty)
	# Keeps track of the location of baddies on the spawn line so that they don't overlap and trigger spawn issues
	var baddie_location_per_spawn_line = {}
	# Decide on the baddie types for each spawn location
	var baddie_type_per_spawn = set_spawn_baddie_type()
	
	# Spawn each baddie
	for _i in range(no_baddies):
		# Select a random spawn point/line
		var spawn_place = combined_baddie_spawns[randi()%combined_baddie_spawns.size()]
		var baddie_name = baddie_type_per_spawn[spawn_place.name]

		# This is here for demonstrative purposes and does nothing 
		var baddie_instance = difficulty_controller.get_baddie_instance(baddie_name, room_difficulty)

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

			spawn_place.get_parent().add_child(baddie_instance)
			baddie_instance.position = random_point

func set_spawn_baddie_type() -> String:
	var spawn_baddie_type = {}
	var selected_baddie
	var baddie_instance
#	var new_baddie_instance 
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
		spawn_baddie_type[spawn_place.name] = selected_baddie
	return spawn_baddie_type
	
# Spawnsmitems at the item locations
func spawn_items():
	# Retrieve the list of default items
	var default_possible_items = item_drop_chances.item_weights.keys()
	var possible_items
	for node in item_spawn_nodes:
		var item_children = node.get_children()
		var item_names = []
		for item in item_children:
			if item.name == 'health_pickup':
				item_names.append('HealthPickup')
			else:
				item_names.append(item.name)
			item.queue_free()
		
		# If there are item children on the node then use those items as the default
		if len(item_children) > 0:
			possible_items = item_names
		else:
			possible_items = default_possible_items
		
		var item_instance = item_drop_chances.get_random_item(possible_items)
		if node.is_inside_tree():
			item_instance.global_position = node.global_position
		node.get_parent().add_child(item_instance)

	
func get_baddie_list():
	var baddie_filenames = ['BearBoi.tscn', 'FlyBoi.tscn','Chick.tscn']
	return baddie_filenames[randi() % baddie_filenames.size]
	
func shuffle_list(list):
	var shuffled_list = []
	var index_list = range(list.size())
	for _i in range(list.size()):
		randomize()
		var x = randi()%index_list.size()
		shuffled_list.append(list[x])
		index_list.remove(x)
		list.remove(x)
	return shuffled_list
	
func setup_player_camera():
	# Set the player to have the camera
	var player_camera = Utils.Player.get_node('Camera2D')
	player_camera.current = true
	
	# Check if there are room limits set for the camera, uses tilemap if not.
	if not get_node_or_null("camera_limit_NW") or not get_node_or_null("camera_limit_SE"):
		var map_limits = get_node("BaseTiles").get_used_rect()
		var map_cellsize = get_node("BaseTiles").cell_size
		player_camera.limit_left = map_limits.position.x * map_cellsize.x
		player_camera.limit_right = map_limits.end.x * map_cellsize.x
		player_camera.limit_top = map_limits.position.y * map_cellsize.y
		player_camera.limit_bottom = map_limits.end.y * map_cellsize.y
	
	else:
		player_camera.limit_left = get_node('camera_limit_NW').position.x
		player_camera.limit_right = get_node('camera_limit_SE').position.x
		player_camera.limit_top = get_node('camera_limit_NW').position.y
		player_camera.limit_bottom = get_node('camera_limit_SE').position.y


#Level Change Signalling - Likely a far better way to write this code.
func _on_Exit_UP_body_entered(body):
	if body.is_in_group("Player"):
		print("Exit UP")
		emit_signal("indicate_room_change", Vector2.UP, 'DOWN')


func _on_Exit_DOWN_body_entered(body):
	if body.is_in_group("Player"):
		print("Exit DOWN")
		emit_signal("indicate_room_change", Vector2.DOWN, 'UP')


func _on_Exit_LEFT_body_entered(body):
	if body.is_in_group("Player"):
		print("Exit LEFT")
		emit_signal("indicate_room_change", Vector2.LEFT, 'RIGHT')


func _on_Exit_RIGHT_body_entered(body):
	if body.is_in_group("Player"):
		print("Exit RIGHT")
		emit_signal("indicate_room_change", Vector2.RIGHT,'LEFT')
		
		
#---------- ROOM TELEPORTER IN DEBUG ----------
func _input(_event):
	if OS.is_debug_build():
		
		if Input.is_action_just_pressed("map_left") and get_node_or_null("Exit_LEFT"):
			emit_signal("indicate_room_change", Vector2.LEFT, 'RIGHT')
			
		elif Input.is_action_just_pressed("map_down") and get_node_or_null("Exit_DOWN"):
			emit_signal("indicate_room_change", Vector2.DOWN, 'UP')
			
		elif Input.is_action_just_pressed("map_up") and get_node_or_null("Exit_UP"):
				emit_signal("indicate_room_change", Vector2.UP, 'DOWN')
				
		elif Input.is_action_just_pressed("map_right") and get_node_or_null("Exit_RIGHT"):
			emit_signal("indicate_room_change", Vector2.RIGHT,'LEFT')

