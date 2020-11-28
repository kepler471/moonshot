extends State
# Horizontal movement on the ground.
# Delegates movement to its parent Move state and extends it
# with state transitions


func unhandled_input(event: InputEvent) -> void:
	_parent.unhandled_input(event)


func physics_process(delta: float) -> void:
	if owner.is_on_floor() and owner.floor_detector.is_close_to_floor():
		if _parent.get_move_direction().x == 0.0:
			_state_machine.transition_to("Move/Idle")
	else:
		_state_machine.transition_to("Move/Air")
	_parent.physics_process(delta)


func enter(msg: Dictionary = {}) -> void:
	owner.get_node("SFX").play("running")
	_parent.enter(msg)


func exit() -> void:
	owner.get_node("SFX").stop("running")
	_parent.exit()
