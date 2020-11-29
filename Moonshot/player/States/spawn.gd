tool
extends State
# Safety for player spawn

onready var safe_period: Timer = $SafePeriod


func _get_configuration_warning() -> String:
	return "" if $SafePeriod else "%s requires a Timer child named SafePeriod" % name


func unhandled_input(event: InputEvent) -> void:
	_parent.unhandled_input(event)


func enter(msg: Dictionary = {}) -> void:
	if "room" in msg:
		owner.set_invulnerable(2, "spawn")
	_state_machine.transition_to("Move/Idle")

func exit() -> void:
	_parent.exit()
