extends Node2D

var inside_exit = false


func _ready():
	add_child(Utils.Player)
	Utils.Player.position = Vector2(-137,153)
	Utils.Player.get_node("Camera2D").set_zoom(Vector2(0.75,0.75))
	Utils.Player.get_node("Camera2D").position += Vector2(0,-150)
	Utils.Player.state_machine.transition_to("Move/Spawn", {"room": true})
	Utils.Player.safety = true

func _input(event):
	if event.is_action_pressed("enter") and inside_exit:
		get_tree().quit()
		

func _on_ExitButton_body_entered(body):
	inside_exit = true


func _on_ExitButton_body_exited(body):
	inside_exit = false
