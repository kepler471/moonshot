extends Node2D

func _ready():
	add_child(Utils.Player)
	Utils.Player.position = Vector2(-137,153)
	Utils.Player.get_node("Camera2D").set_zoom(Vector2(0.75,0.75))
	Utils.Player.get_node("Camera2D").position += Vector2(0,-150)
	Utils.Player.state_machine.transition_to("Move/Spawn", {"room": true})
	Utils.Player.safety = true
