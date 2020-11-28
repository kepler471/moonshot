extends RigidBody2D

const PICK_UP_TRAVEL_SPEED = 0.01
const FIRE_RATE_INCREASE = 1
const PLAYER_SIGNAL = "emit_player_global_position_drop"
const MOVE_TO_PLAUER = "move_to_player"

func _ready():
	_connect()

func move_to_player(player_global_position):
	if !is_inside_tree() && _is_connected():
		CombatSignalController.disconnect(PLAYER_SIGNAL, self, MOVE_TO_PLAUER);
	else:
		if !_is_connected():
			_connect()
		float_to_player(player_global_position)

func float_to_player(player_global_position) -> void:
	var shot_direction: Vector2 = (player_global_position - get_global_position()).normalized()
	position = self.global_position + (shot_direction * 0.01)
	apply_central_impulse(shot_direction * PICK_UP_TRAVEL_SPEED)
	rotation = PI + position.angle_to_point(player_global_position)

func _connect() -> void:
	CombatSignalController.connect(PLAYER_SIGNAL, self, MOVE_TO_PLAUER)

func _is_connected() -> bool:
	return CombatSignalController.is_connected(PLAYER_SIGNAL, self, MOVE_TO_PLAUER)

func _on_FirerateDrop_body_entered(body):
	if body.is_in_group('Player'):
		Utils.player_stats.pickup_firerate(FIRE_RATE_INCREASE)
		self.queue_free()
