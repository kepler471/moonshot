extends Node2D


var health_bonus = 0.5


func _on_Area2D_body_entered(body):
	if body.is_in_group('Player'):
		body.add_health(health_bonus)
		queue_free()
