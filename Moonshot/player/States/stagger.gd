tool
extends State


#onready var duration: Timer = $Duration


#func _get_configuration_warning() -> String:
#	return "" if $Duration else "%s requires a Timer child named Duration" % name
#func physics_process(delta):
#	_parent.physics_process(delta)

func enter(msg: Dictionary = {}):
#	_parent.enter(_msg)
#	print(_parent.name)
	print("Stagger entered")
	
#	duration.start()
#	yield(duration, "timeout")
	if msg.previous.name == "Move/Air":
		_state_machine.transition_to("Move/Air", {"stagger": Vector2(msg.direction * 500, 0)})
	else:
		_state_machine.transition_to("Move/Air", {"stagger": Vector2(msg.direction * 500, -500)})
