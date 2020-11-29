extends RigidBody2D

func _process(delta):
	if !is_inside_tree():
		call_deferred("free")

func _on_FirerateDrop_body_entered(body):
	if body.is_in_group('Player'):
		Utils.player_stats.unlock_firerate_level()
		call_deferred("free")
