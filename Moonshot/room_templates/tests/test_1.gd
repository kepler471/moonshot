extends Node2D



#export(PackedScene) var StartLevel := preload("res://room_templates/tests/test_1.tscn")

#var visited_checkpoints := {}
#var level: Node2D = null


func _ready() -> void:
#	LevelLoader.setup(self, $player, StartLevel)
# warning-ignore:return_value_discarded
#	Events.connect("checkpoint_visited", self, "_on_Events_checkpoint_visited")

	if get_node("camera_limit_NW") == null || get_node("camera_limit_SE") == null:
		var map_limits = get_node("TileMap").get_used_rect()
		var map_cellsize = get_node("TileMap").cell_size
		$Player/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
		$Player/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
		$Player/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
		$Player/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y
		print(map_limits)
		print(map_cellsize)
	
	else:
		$Player/Camera2D.limit_left = $camera_limit_NW.position.x
		$Player/Camera2D.limit_right = $camera_limit_SE.position.x
		$Player/Camera2D.limit_top = $camera_limit_NW.position.y
		$Player/Camera2D.limit_bottom = $camera_limit_SE.position.y


#func _on_Events_checkpoint_visited(checkpoint_name: String) -> void:
#	visited_checkpoints[level.name] = visited_checkpoints.get(level.name, [])
#	visited_checkpoints[level.name].push_back(checkpoint_name)


#func _unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed("restart"):
## warning-ignore:return_value_discarded
#		get_tree().reload_current_scene()
#	elif event.is_action_pressed("DEBUG_die"):
#		var last_checkpoint_name: String = visited_checkpoints[level.name].back()
#		var last_checkpoint: Area2D = level.get_node("Checkpoints/" + last_checkpoint_name)
#		$player.state_machine.transition_to("Die", {last_checkpoint = last_checkpoint})
#	elif event.is_action_pressed("toggle_full_screen"):
#		OS.window_fullscreen = not OS.window_fullscreen
