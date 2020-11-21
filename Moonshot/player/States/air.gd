tool
extends State
# Manages Air movement, including jumping and landing.
# You can pass a msg to this state, every key is optional:
# {
	# velocity: Vector2, to preserve inertia from the previous state
	# impulse: float, to make the character jump
	# wall_jump: bool, to take air control off the player for controls_freeze.wait_time seconds upon entering the state
# }
# The player can jump after falling off a ledge. See unhandled_input and jump_delay.


signal jumped

onready var jump_delay: Timer = $JumpDelay
onready var controls_freeze: Timer = $ControlsFreeze

export var acceleration_x := 2500.0
export var jump_deceleration := 5000.0
export var air_resistance := 1250.0

var enabled_air_resistance := true
var velocity

func unhandled_input(event: InputEvent) -> void:
	# Jump after falling off a ledge
	if event.is_action_pressed("jump"):
		if _parent.velocity.y >= 0.0 and jump_delay.time_left > 0.0:
			_parent.velocity = calculate_jump_velocity(_parent.jump_impulse)
		emit_signal("jumped")
	else:
		_parent.unhandled_input(event)


func physics_process(delta: float) -> void:
	_parent.physics_process(delta)

	# Variable jump height.
	if not Input.is_action_pressed("jump") and sign(_parent.velocity.y) == sign(Vector2.UP.y):
		_parent.velocity.y += jump_deceleration * delta

	# Air resistance

	## re-enable air resistance if player inputs direction after wall jump
	if (
		not enabled_air_resistance and
		(Input.is_action_pressed("move_left") or
		 Input.is_action_pressed("move_right"))
	):
		enabled_air_resistance = true

	## apply air resistance
	if (
		enabled_air_resistance and
		(not Input.is_action_pressed("move_left") or
		 not Input.is_action_pressed("move_left"))
	):
		_parent.velocity.x -= sign(_parent.velocity.x) * air_resistance * delta

	Events.emit_signal("player_moved", owner)

	var ld = owner.ledge_wall_detector

	# Landing
	if owner.is_on_floor():
		var target_state := "Move/Idle" if _parent.get_move_direction().x == 0 else "Move/Run"
		_state_machine.transition_to(target_state)

	# Grab Wall
	elif owner.is_on_wall() and ld.is_against_wall() and not ld.is_hanging():
		var wall_normal: float = owner.get_slide_collision(0).normal.x
		_state_machine.transition_to("Move/Wall", {"normal": wall_normal, "velocity": _parent.velocity})


func enter(msg: Dictionary = {}) -> void:
	_parent.enter(msg)
	
	_parent.acceleration.x = acceleration_x
	_parent.snap_vector.y = 0
	if "velocity" in msg:
		if msg.velocity != null:
			_parent.velocity = msg.velocity 
			velocity = msg.velocity
			_parent.max_speed.x = max(abs(msg.velocity.x), _parent.max_speed.x)
	if "impulse" in msg:
		_parent.velocity += calculate_jump_velocity(msg.impulse)
	if "stagger" in msg:
		_parent.velocity += msg.stagger
	if "wall_jump" in msg:
		controls_freeze.start()
		_parent.acceleration = Vector2(acceleration_x, _parent.acceleration_default.y)
		_parent.max_speed.x = max(abs(_parent.velocity.x), _parent.max_speed_default.x)
		jump_delay.start()
		enabled_air_resistance = false
	else:
		enabled_air_resistance = true


func exit() -> void:
	_parent.acceleration = _parent.acceleration_default
	enabled_air_resistance = true # TODO: Check if this is redundant
	_parent.exit()


# Returns a new velocity with a vertical impulse applied to it
func calculate_jump_velocity(impulse: float = 0.0) -> Vector2:
	return _parent.calculate_velocity(
		_parent.velocity,
		_parent.max_speed,
		Vector2(0.0, impulse),
		1.0,
		Vector2.UP
	)


func _get_configuration_warning() -> String:
	return "" if $JumpDelay else "%s requires a Timer child named JumpDelay" % name
