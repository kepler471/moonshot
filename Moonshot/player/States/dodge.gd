tool
extends State

onready var dodge_period: Timer = $DodgePeriod

var layer_default
var mask_default
const layer_dodge = 4 # Baddie layer
const mask_dodge = 9 # Walls & PassThrough

export var dodge_speed := 2500.0
var dodge_dir


func _get_configuration_warning() -> String:
	return "" if $DodgePeriod else "%s requires a Timer child named DodgePeriod" % name


func physics_process(delta) -> void:
	if owner.is_on_floor() and not dodge_period.is_stopped():
		_parent.velocity.x = dodge_speed * dodge_dir
		_parent.physics_process(delta)
	
	if dodge_period.is_stopped():
		_parent.max_speed = _parent.max_speed_default
		owner.set_collision_layer(layer_default)
		owner.set_collision_mask(mask_default)
		_state_machine.transition_to("Move/Run")

func enter(_msg: Dictionary = {}) -> void:
	dodge_period.start()
	_parent.max_speed.x = dodge_speed
	dodge_dir = owner.facing
	
	owner.set_invulnerable(dodge_period.get_wait_time(), "dodge")
	
	layer_default = owner.get_collision_layer()
	mask_default = owner.get_collision_mask()
	
	# Changing the collisions layer and mask of Player during dodge
	owner.set_collision_layer(4)
	owner.set_collision_mask(9)
	
