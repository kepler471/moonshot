extends Node2D

const MAIN_GAME : bool = true #flag for room testing

var level_gen = preload("res://procedural_map_generation/level_gen.gd")
var HUD_manager = preload("res://HUD.gd").new()

var room_index = Vector2(0, 0)
var current_room_node = null
var level_map 
var minimap
var level_no = 1
const death_screen_delay = 3

func _ready():
	start_level(level_no)
	CombatSignalController.connect('player_kill', self, 'activate_death_screen')
	add_child(HUD_manager)
	HUD_manager.build_hud(minimap)

	
func activate_death_screen():
	yield(get_tree().create_timer(death_screen_delay), "timeout")
	$DeathScreen/Visibility.visible = true
	get_tree().paused = true
	
func go_up_level():
	level_no += 1
	TileSheetLoader.update_level_no()
	current_room_node.get_node("Player").queue_free()
	current_room_node.queue_free()
	level_map.clear()
	var minimap_gui_box = get_node('GUI/MinimapBox/MinimapBackground')
	minimap.set_minimap_size(minimap_gui_box.rect_size / 2)
	Utils.reset_player()
	CombatSignalController.connect('player_kill', self, 'activate_death_screen')
	start_level(level_no)
	
	
func start_level(level_num):
	
	# Generate level and minimap
	var returns = level_gen.new(level_num)
	level_map =  returns.gen.map
	minimap = returns.minimap
	var minimap_gui_box = get_node('GUI/MinimapBox/MinimapBackground')
	minimap.set_minimap_size(minimap_gui_box.rect_size / 2)
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
	call_deferred("spawn_safely")
	call_deferred("set_player_velocity", new_entrance)
	current_room_node.setup_player_camera()
	
	get_tree().paused = false

func set_player_velocity(new_entrance):
	if new_entrance == 'DOWN':
		Utils.Player.state_machine.transition_to("Move/Air", {"impulse": 1010.0})

func spawn_safely() -> void:
	Utils.Player.state_machine.transition_to("Move/Spawn", {"room": true})
#	pass
