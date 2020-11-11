extends Node2D

signal level_change(exit_key)


#Camera Limits
func _ready():

	if get_node("camera_limit_NW") == null || get_node("camera_limit_SE") == null:
		var map_limits = get_node("BaseTiles").get_used_rect()
		var map_cellsize = get_node("BaseTiles").cell_size
		$Player/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
		$Player/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
		$Player/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
		$Player/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y
	
	else:
		$Player/Camera2D.limit_left = $camera_limit_NW.position.x
		$Player/Camera2D.limit_right = $camera_limit_SE.position.x
		$Player/Camera2D.limit_top = $camera_limit_NW.position.y
		$Player/Camera2D.limit_bottom = $camera_limit_SE.position.y


#Level Change Signalling - Likely a far better way to write this code.
func _on_Exit_N_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("level_change", [1,0,0,0])

func _on_Exit_S_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("level_change", [0,0,1,0])

func _on_Exit_W_body_entered(body):
	if body.is_in_group("Player"):
		print("Exit West")
		emit_signal("level_change", [0,0,0,1])

func _on_Exit_E_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("level_change", [0,1,0,0])
