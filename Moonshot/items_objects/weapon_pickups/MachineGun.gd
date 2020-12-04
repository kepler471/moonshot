extends Node2D


func _on_Area2D_body_entered(body):
	if body.is_in_group('Player'):
		Utils.player_arsenal.set_weapon("machine_gun")
		Utils.player_arsenal.get_weapon().pickup_ammo()
		Utils.player_arsenal.update_hud()
		body.set_arm_sprite('machine_gun')
		queue_free()
