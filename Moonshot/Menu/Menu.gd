extends Node2D

func _ready():
	$Player.get_node("Camera2D").position += Vector2(0,-120)

func activate_lift():
	$ExitLift.activate_lift()
