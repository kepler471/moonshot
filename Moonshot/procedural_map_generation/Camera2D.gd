extends Camera2D

var dragging: bool = false
var lastpos = Vector2.ZERO

func _input(event):
	
	#set and unset dragging bool
	if event.is_action_pressed("DragCamera"):
		dragging = true
		lastpos = get_global_mouse_position()
	elif event.is_action_released("DragCamera"):
		dragging = false
	if (event is InputEventMouseMotion) && dragging:
		position -= event.relative
