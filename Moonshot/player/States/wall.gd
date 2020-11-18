tool
extends State
# Handles wall movement: sliding against the wall and wall jump


export var slide_acceleration := 1600.0
export var max_slide_speed := 200.0
export (float, 0.0, 1.0) var friction_factor := 0.15

export var jump_strength := Vector2(500.0, 800.0)
var _wall_normal := -1
var _velocity := Vector2.ZERO
var wall_grace_counter = 0

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump()


func physics_process(delta: float) -> void:
	if _velocity.y > max_slide_speed:
		_velocity.y = lerp(_velocity.y, max_slide_speed, friction_factor)
	else:
		_velocity.y += slide_acceleration * delta
	_velocity.y = clamp(_velocity.y, -max_slide_speed, max_slide_speed)
	_velocity = owner.move_and_slide_with_snap(_velocity, Vector2(-_wall_normal, 0), owner.FLOOR_NORMAL)

	var ld = owner.ledge_wall_detector
	var is_moving_away_from_wall := sign(_parent.get_move_direction().x) == sign(_wall_normal)

	if owner.is_on_floor():
		_state_machine.transition_to("Move/Idle")

	elif is_moving_away_from_wall:
		wall_grace_counter += 1
		#Gives the player time to wall jump as they move away from the wall
		if wall_grace_counter > 5:
			_state_machine.transition_to("Move/Air", {"velocity": _velocity})
	
	elif !is_moving_away_from_wall and wall_grace_counter > 0:
		wall_grace_counter = 0

	# Drop player if they are hanging by top portion of body only
	elif ld.is_hanging():
		_state_machine.transition_to("Move/Air", {"velocity": _velocity})

	elif ld.is_against_ledge():
		_state_machine.transition_to("Ledge", {move_state = _parent})


func enter(msg: Dictionary = {}) -> void:
	_parent.enter(msg)

	_wall_normal = msg.normal
	_velocity.y = clamp(msg.velocity.y, -max_slide_speed, max_slide_speed)


func exit() -> void:
	_parent.exit()


func jump() -> void:
	# The direction vector not being normalized is intended
	var impulse := Vector2(_wall_normal, -1.0) * jump_strength
	var msg := {
		velocity = impulse,
		wall_jump = true
	}
	_state_machine.transition_to("Move/Air", msg)
