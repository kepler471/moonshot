tool
extends State
# Safety for player spawn

onready var safe_period: Timer = $SafePeriod


func _get_configuration_warning() -> String:
	return "" if $DodgePeriod else "%s requires a Timer child named SpawnPeriod" % name


func unhandled_input(event: InputEvent) -> void:
	_parent.unhandled_input(event)


func enter(msg: Dictionary = {}) -> void:
	if "room" in msg:
		owner.set_invulnerable(safe_period.get_wait_time(), "idle")

#		layer_default = owner.get_collision_layer()
#		mask_default = owner.get_collision_mask()
#
#		# Changing the collisions layer and mask of Player during dodge
#		owner.set_collision_layer(4)
#		owner.set_collision_mask(9)
	_state_machine.transition_to("Move/Idle")

func exit() -> void:
	pass
