extends State
# Pulls the character up a ledge, temporarily taking control away from the player


func enter(msg: Dictionary = {}) -> void:
	assert("move_state" in msg and msg.move_state is State)
	var start: Vector2 = owner.global_position
	var ld = owner.ledge_wall_detector
	owner.global_position = ld.get_mid_global_position() + ld.get_cast_to_directed()
	owner.global_position = owner.floor_detector.get_floor_position()
	msg.move_state.velocity.y = 0.0
	_state_machine.transition_to("Move/Run")

func exit() -> void:
	pass

