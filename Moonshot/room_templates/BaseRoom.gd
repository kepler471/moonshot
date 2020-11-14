extends Node2D

signal indicate_room_change(exit_key, entrance)

#Camera Limits
func _ready():
	pass


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
