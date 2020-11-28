extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_FirerateDrop_body_entered(body):
	if body.is_in_group('Player'):
		Utils.player_stats.unlock_firerate_level()
		self.queue_free()

