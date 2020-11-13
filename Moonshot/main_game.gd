extends Node2D



# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var level_gen = preload("res://procedural_map_generation/level_gen.gd")
var player_scene = load("res://player/player.tscn")
var Player = player_scene.instance()
var room_index = Vector2(0, 0)
var current_room_node = null
var level_map 
var player_camera
var room
var room_changed = false
var previous_room_idx
var new_entrance
var debug = true
var minimap
var player_spawn_position
var last_time = 0

func _ready():
	start_level(1)
	build_hud()
	
func build_hud():
	$GUI.add_child(minimap.minimap_node)
	minimap.minimap_node.position = Vector2(900, 500)

	
func start_level(level_num):
	# Run the procedural map generation andreturn the map ofthe rooms and the minimap obejcts
	var returns = level_gen.new(1)
	level_map =  returns.gen.map
	minimap = returns.minimap
	
	
	# Instance the first room and set it to the current room
	get_and_instance()
	
	# Add the player to the current room
	current_room_node.add_child(Player)
	
	# Focus the camera around the player
	setup_player_camera()
	
	# Move the player to the spawn node in the map
	player_spawn_position = current_room_node.get_node('player_spawn').position
	Player.position = player_spawn_position
	
	# Add the room instance to the current scene
	add_child(current_room_node)
	
	# Connect the indicate room_change function to the emitting signal
	current_room_node.connect("indicate_room_change",self,"indicate_room_change")

func get_and_instance():
	# Fetch the new room from the room index
	room = level_map[room_index]
	
	# Check if the room has already been instanced (dont want a fight every time you go back haha)
	if not room.is_instanced():
		room.instance()
	
	# Replace the current room with the new room & connect to the indicating signal
	current_room_node = room.get_instance()
	current_room_node.connect("indicate_room_change",self,"indicate_room_change")
	
# Runs all the time
func _process(delta):
	# When there has been a room change indicated then change room

	var this_time = OS.get_ticks_msec()
	if (this_time - last_time > 100) && room_changed:
		last_time = OS.get_ticks_msec()
		room_changed = false
		
		change_room()
		# Update minimap
		minimap.change_current_node(room_index, previous_room_idx)

# Signal called by the room script on player collision with the exits
func indicate_room_change(room_change : Vector2, room_door_entrance):
	# Check how long ago the room was last changed, ensure duplicate signals are not sent

	var current_time = OS.get_ticks_msec()
	if current_time - last_time > 10:
		room_changed = true
		last_time = OS.get_ticks_msec()
		previous_room_idx = room_index + Vector2(0, 0)
		room_index = room_index + room_change
		print("Room index changed by " + str(room_change) + " the new room index is: " + str(room_index))
		new_entrance = room_door_entrance

# Run to change room to the new room that has already been set by indicate_room_change
func change_room():
	# Pause the current room whilst chaning 
	get_tree().paused = true
	
	# Turn off all physics in the room being exited
	current_room_node.visible = false
	current_room_node.set_process(false)
	current_room_node.set_physics_process(false)
	current_room_node.set_process_input(false)


	var nodes_in_old_room = current_room_node.get_children()
	if debug:
		for node in nodes_in_old_room:
			print("Old Room Child Name: " + node.name)
			
	# Remove the player from the current room
	current_room_node.remove_child(Player)
	remove_child(current_room_node)
	
	# Get the new room
	get_and_instance()
	
	# Fetch position of the relevant door
	var current_room_template = level_map[room_index].get_template_name()
	print("The current room template is: " + str(current_room_template))
	var door_position = current_room_node.get_node('Exit_' + new_entrance).position

	# Update player position relative to the door to prevent instant collision
	if new_entrance == 'UP':
		Player.position = door_position + Vector2(0, 60)
	elif new_entrance == 'DOWN':
		Player.position = door_position + Vector2(0, -40)
	elif new_entrance == 'RIGHT':
		Player.position = door_position + Vector2(-40, 46)
	elif new_entrance == 'LEFT':
		Player.position = door_position + Vector2(40, 46)
	if debug:
		print("Position of player:  " + str(Player.position.x) + ', ' + str(Player.position.y))
		print('The new room door entrance ' + str(new_entrance) + ' is at ' + str(door_position))

	# Add the child to the room and the new room to the scene
	current_room_node.add_child(Player)
	add_child(current_room_node)

	# Set up the player camera to the new room
	setup_player_camera()
	
	if debug:
		var nodes_in_room = current_room_node.get_children()
		for node in nodes_in_room:
			print("Current Room Child Name: " + node.name)
		var nodes_in_main_game = get_children()
		for node in nodes_in_main_game:
			print("Main Game Node: " + node.name)

	# Activte the new room's physics
	current_room_node.set_process(true)
	current_room_node.set_physics_process(true)
	current_room_node.set_process_input(true)
	get_tree().paused = false
	current_room_node.visible = true
	

	# Insert logic to spawn at the bottom of the door for horizontal movement

	


func setup_player_camera():
	# Set the player to have the camera
	player_camera = current_room_node.get_node('Player/Camera2D')
	player_camera.current = true
	
	# Check if there are room limits set for the camera andguess them if not
	if current_room_node.get_node("camera_limit_NW") == null || current_room_node.get_node("camera_limit_SE") == null:
		var map_limits = current_room_node.get_node("BaseTiles").get_used_rect()
		var map_cellsize = current_room_node.get_node("BaseTiles").cell_size
		Player.get_node('Camera2D').limit_left = map_limits.position.x * map_cellsize.x
		Player.get_node('Camera2D').limit_right = map_limits.end.x * map_cellsize.x
		Player.get_node('Camera2D').limit_top = map_limits.position.y * map_cellsize.y
		Player.get_node('Camera2D').limit_bottom = map_limits.end.y * map_cellsize.y
	
	else:
		Player.get_node('Camera2D').limit_left = current_room_node.get_node('camera_limit_NW').position.x
		Player.get_node('Camera2D').limit_right = current_room_node.get_node('camera_limit_SE').position.x
		Player.get_node('Camera2D').limit_top = current_room_node.get_node('camera_limit_NW').position.y
		Player.get_node('Camera2D').limit_bottom = current_room_node.get_node('camera_limit_SE').position.y


	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
