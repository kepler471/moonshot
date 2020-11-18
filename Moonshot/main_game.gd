extends Node2D

var level_gen = preload("res://procedural_map_generation/level_gen.gd")
var player_scene = load("res://player/player.tscn")
var Player = player_scene.instance()
var room_index = Vector2(0, 0)
var current_room_node = null
var level_map 
var minimap

func _ready():
	start_level(1)
	build_hud()
	
	
func build_hud():
	$GUI.add_child(minimap.minimap_node)
	minimap.minimap_node.position = Vector2(900, 500)

func _process(delta):
	var new_health_bar_size = (Player.stats.health*100) / Player.stats.max_health
	if new_health_bar_size > 0:
		get_node("GUI/ColorRect").rect_size.y = new_health_bar_size
	else:
		get_node("GUI/ColorRect").rect_size.y = 0
		
func start_level(level_num):
	
	# Generate level and minimap
	var returns = level_gen.new(1)
	level_map =  returns.gen.map
	minimap = returns.minimap
	
	get_room_instance(room_index)
	
	current_room_node.add_child(Player)
	Player.position = current_room_node.get_node('player_spawn').position
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

	get_tree().paused = true
	current_room_node.get_node("Player").queue_free()
	remove_child(current_room_node)
	get_room_instance(room_index)
	
	Player = player_scene.instance()
#----- I think player pos change should be moved to Baseroom.gd ------
	#Move player to door entrance.
	var door_position = current_room_node.get_node('Exit_' + new_entrance).position
	
	if new_entrance == 'UP':
		Player.position = door_position + Vector2(0, 60)
	elif new_entrance == 'DOWN':
		Player.position = door_position + Vector2(0, -40)
	elif new_entrance == 'RIGHT':
		Player.position = door_position + Vector2(-40, 46)
	elif new_entrance == 'LEFT':
		Player.position = door_position + Vector2(40, 46)
	
	current_room_node.add_child(Player)
	call_deferred("add_child",current_room_node)

	current_room_node.setup_player_camera()
	
	get_tree().paused = false


