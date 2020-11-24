extends Node2D

signal indicate_room_change(exit_key, entrance)

const MAIN_GAME : bool = false

func _ready():
	if get_tree().get_current_scene().MAIN_GAME == false:
		self.add_child(Utils.Player)
		Utils.Player.position = self.get_node("testing_player_spawn").position
		self.setup_player_camera()


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
func _input(event):
	if OS.is_debug_build():
		
		if Input.is_action_just_pressed("map_left") and get_node_or_null("Exit_LEFT"):
			emit_signal("indicate_room_change", Vector2.LEFT, 'RIGHT')
			
		elif Input.is_action_just_pressed("map_down") and get_node_or_null("Exit_DOWN"):
			emit_signal("indicate_room_change", Vector2.DOWN, 'UP')
			
		elif Input.is_action_just_pressed("map_up") and get_node_or_null("Exit_UP"):
				emit_signal("indicate_room_change", Vector2.UP, 'DOWN')
				
		elif Input.is_action_just_pressed("map_right") and get_node_or_null("Exit_RIGHT"):
			emit_signal("indicate_room_change", Vector2.RIGHT,'LEFT')

