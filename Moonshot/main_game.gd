extends Node2D

var level_gen = preload("res://procedural_map_generation/level_gen.gd")
var room_index = Vector2(0, 0)
var current_room_node = null
var level_map 
var minimap
var level_no = 1

func _ready():
	start_level(level_no)
	build_hud()
	
func go_up_level():
	level_no += 1
	current_room_node.get_node("Player").queue_free()
	current_room_node.queue_free()
	level_map.clear()
	Utils.reset_player()
	start_level(level_no)
	
	
func build_hud():
	$GUI.add_child(minimap.minimap_node)
	minimap.minimap_node.position = Vector2(900, 500)
	Utils.player_stats.connect("firerate_changed",self,"update_firerate_hud") #signal from BaseRoom.gd
	update_firerate_hud(Utils.player_stats.modifiers['firerate_pickups'], Utils.player_stats.current_firerate_level)

func _process(delta):
	var new_health_bar_size = (Utils.player_stats.health*154) / Utils.player_stats.max_health
	var health_bar = get_node("GUI/MarginContainer/VBoxContainer/VBoxContainer3/VBoxContainer2/HBoxContainer2/HealthBar")
	if new_health_bar_size > 0:
		health_bar.rect_min_size.x = new_health_bar_size
	else:
		health_bar.rect_min_size.x = 0
	update_firerate_hud(Utils.player_stats.modifiers['firerate_pickups'], Utils.player_stats.current_firerate_level)

func update_firerate_hud(new_firerate, firerate_level):
	var firerate_level_path = "/root/GUI/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/ColorRect/Level"
	for level in range(1, Utils.player_stats.max_firerate_level):
		var level_box = find_node('Level' + str(level))
		if level < firerate_level:
			level_box.color = Color8(21, 184, 39)
		else:
			level_box.color = Color8(27, 66, 147)
			
	# Now scale the power par to leveling up the firerate
	var remainder_firerate_pickups = Utils.player_stats.modifiers['firerate_pickups'] % Utils.player_stats.no_firerate_pickups_to_increase_firerate
	var new_firerate_bar_size = remainder_firerate_pickups*104 / Utils.player_stats.no_firerate_pickups_to_increase_firerate
	var firerate_bar = find_node("FirerateIncBar")
	if new_firerate_bar_size  > 0:
		firerate_bar.rect_size.y = new_firerate_bar_size
	else:
		firerate_bar.rect_size.y = 0
		
func start_level(level_num):
	
	# Generate level and minimap
	var returns = level_gen.new(level_num)
	level_map =  returns.gen.map
	minimap = returns.minimap
	
	get_room_instance(room_index)
	
	current_room_node.add_child(Utils.Player)
	Utils.Player.position = current_room_node.get_node('player_spawn').position
	current_room_node.setup_player_camera()
	
	add_child(current_room_node)
	connect_exit_signal()


func get_room_instance(index):
	var room = level_map[index]
	
	if not room.is_instanced():
		room.instance()
		
	current_room_node = room.get_instance()
	connect_exit_signal()
	
	
func connect_exit_signal():
	current_room_node.connect("indicate_room_change",self,"change_room") #signal from BaseRoom.gd
	
	
func change_room(room_change : Vector2, new_entrance):
	
	var previous_room_idx = room_index + Vector2(0, 0)
	room_index = room_index + room_change
	
	minimap.change_current_node(room_index, previous_room_idx)
	var old_entrance
	if new_entrance == "LEFT":
		old_entrance = "RIGHT"
	elif new_entrance == "RIGHT":
		old_entrance = "LEFT"
	elif new_entrance == "UP":
		old_entrance = "DOWN"
	elif new_entrance == "DOWN":
		old_entrance = "UP"
		
	var old_door_position = current_room_node.get_node('Exit_' + old_entrance).position
	var player_door_diff = Utils.Player.position - old_door_position
	
	if (new_entrance == "LEFT") or (new_entrance == "RIGHT"):
		player_door_diff.x = -player_door_diff.x
		
	get_tree().paused = true
	current_room_node.get_node("Player").queue_free()
	remove_child(current_room_node)
	get_room_instance(room_index)

	
#----- I think player pos change should be moved to Baseroom.gd ------
	#Move player to door entrance.
	var door_position = current_room_node.get_node('Exit_' + new_entrance).position

	
	Utils.reset_player()
		
	if new_entrance == 'UP':
		Utils.Player.position = door_position + player_door_diff + Vector2(0, 70)
	elif new_entrance == 'DOWN':
		Utils.Player.position = door_position + player_door_diff + Vector2(0, -60)
	elif new_entrance == 'RIGHT':
		Utils.Player.position = door_position + player_door_diff + Vector2(-40, 0)
	elif new_entrance == 'LEFT':
		Utils.Player.position = door_position + player_door_diff + Vector2(40, 0)
		
	current_room_node.add_child(Utils.Player)
	call_deferred("add_child",current_room_node)
	call_deferred("set_player_velocity", new_entrance)
	current_room_node.setup_player_camera()
	
	get_tree().paused = false

func set_player_velocity(new_entrance):
	if new_entrance == 'DOWN':
		Utils.Player.state_machine.transition_to("Move/Air", {"impulse": 1010.0})

