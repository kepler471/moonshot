extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const PICK_UP_TRAVEL_SPEED = 0.01
const FIRE_RATE_INCREASE = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	CombatSignalController.connect("emit_player_global_position_drop", self, "move_to_player")

	
func move_to_player(player_global_position):
	var shot_direction: Vector2 = (player_global_position - get_global_position()).normalized()

	self.position = self.global_position + (shot_direction * 0.01)
	self.apply_central_impulse(shot_direction * PICK_UP_TRAVEL_SPEED)
	self.rotation = PI + self.position.angle_to_point(player_global_position)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_FirerateDrop_body_entered(body):
	if body.is_in_group('Player'):
		Utils.player_stats.pickup_firerate(FIRE_RATE_INCREASE)
		self.queue_free()

