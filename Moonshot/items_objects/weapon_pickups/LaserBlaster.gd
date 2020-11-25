extends Node2D


func _on_Area2D_body_entered(body):
	if body.is_in_group('Player'):
		Utils.player_arsenal.set_weapon("laser_blaster")
		var weapon = Utils.player_arsenal.get_weapon()
		Utils.player_arsenal.update_hud()
		queue_free()
