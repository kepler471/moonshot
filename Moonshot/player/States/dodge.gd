tool
extends State

onready var controls_freeze: Timer = $ControlsFreeze
export var dodge_speed := 1250.0
var dodge_dir

func physics_process(delta) -> void:
	if owner.is_on_floor() and not controls_freeze.is_stopped():
		_parent.velocity.x = dodge_speed * dodge_dir
		_parent.physics_process(delta)
	
	if controls_freeze.is_stopped():
		_parent.max_speed = _parent.max_speed_default
		_state_machine.transition_to("Move/Run")

func enter(_msg: Dictionary = {}) -> void:
	controls_freeze.start()
	_parent.max_speed.x = dodge_speed
	dodge_dir = owner.facing
