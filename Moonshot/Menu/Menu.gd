extends Node2D

func _ready():
	$ExitLift.activate_lift()
	$Player.get_node("Camera2D").set_zoom(Vector2(0.75,0.75))
	$Player.get_node("Camera2D").position += Vector2(0,-150)
