extends Area2D

var entered_body

func _input(event):
	if Input.is_action_pressed("enter") && entered_body:
		var main_scene = get_tree().get_root().get_node('MainGame')
		main_scene.go_up_level()


func _on_Node2D_body_entered(body):
	if body.is_in_group('Player'):
		entered_body = body
		
func _on_Node2D_body_exited(body):
	if body.is_in_group('Player'):
		entered_body = null

