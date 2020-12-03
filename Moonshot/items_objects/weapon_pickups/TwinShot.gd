extends Node2D



func _on_Area2D_body_entered(body):
	if body.is_in_group('Player'):
		Utils.player_arsenal.set_weapon("twin_shot")
		Utils.player_arsenal.get_weapon().pickup_ammo()
		Utils.player_arsenal.update_hud()
		body.set_arm_sprite("twin_shot")
		queue_free()
