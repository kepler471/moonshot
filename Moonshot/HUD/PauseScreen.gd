extends CanvasLayer


var buttons = ['ResumeButton', 'RestartButton', 'ExitButton']
var button_index = 0
var selected_color = Color(1, 0, 0)
var deselected_color = Color(1, 1, 1)


func _ready():
	$Visibility.visible = false
	# Select the right button
	change_button(0, 0)
	
	
	
func _input(event):
	if event.is_action_pressed("enter") && $Visibility.visible:
		if buttons[button_index] == 'ResumeButton':
			$Visibility.visible = false
			get_tree().paused = false
		elif buttons[button_index] == 'RestartButton':
			Utils.restart_game()
			get_tree().reload_current_scene()
			get_tree().paused = false
		elif buttons[button_index] == 'ExitButton':
			get_tree().quit()
	
	if event.is_action_pressed('pause'):
		$Visibility.visible = not $Visibility.visible
		get_tree().paused = not get_tree().paused
		change_button(button_index, 0)
		button_index = 0
		


	elif event.is_action_pressed('move_up') && $Visibility.visible:
		var old_index = button_index + 0
		button_index -= 1
		button_index = max(button_index, 0)
		change_button(old_index, button_index)


	elif event.is_action_pressed('move_down') && $Visibility.visible:
		var old_index = button_index + 0
		button_index += 1
		button_index = min(button_index, 2)
		change_button(old_index, button_index)

func change_button(old_index, new_index):
		var previous_button = find_node(buttons[old_index])
		previous_button.add_color_override("font_color", deselected_color)
		var current_button = find_node(buttons[new_index])
		current_button.add_color_override("font_color", selected_color)
		


