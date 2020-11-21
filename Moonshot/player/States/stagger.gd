tool
extends State



func enter(msg: Dictionary = {}):
	if msg.previous.name == "Move/Air":
		_state_machine.transition_to("Move/Air", {"stagger": Vector2(msg.direction * 250, 0)})
	else:
		_state_machine.transition_to("Move/Air", {"stagger": Vector2(msg.direction * 500, -500)})