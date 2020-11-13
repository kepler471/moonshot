extends Node2D


func _ready() -> void:

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

