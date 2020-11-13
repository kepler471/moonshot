extends Node2D



# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass




func _process(delta):

	var play_button = get_node('PlayButton')
	var exit_button = get_node('ExitButton')
	var play_button_location = play_button.get_position()
	var exit_button_location = exit_button.get_position()
	var play_button_min_y = play_button_location.y 
	var play_button_max_y = play_button_location.y + 96
	var exit_button_max_y = exit_button_location.y + 96
	var player_position = get_node('Player').get_position()
	var button_pressed = ''

	# Check where the player is in relation to each label 
	# Change their colours, and mark them as selected
	if player_position.y > play_button_min_y && player_position.y < play_button_max_y:
		play_button.add_color_override("font_color", Color(1, 1, 1))
		exit_button.add_color_override("font_color", Color(0, 0, 0))
		button_pressed = 'play'
	elif player_position.y < exit_button_max_y && player_position.y > play_button_min_y:
		exit_button.add_color_override("font_color", Color(1, 1, 1))
		play_button.add_color_override("font_color", Color(0, 0, 0))
		button_pressed = 'exit'
	else:
		play_button.add_color_override("font_color", Color(0, 0, 0))
		exit_button.add_color_override("font_color", Color(0, 0, 0))

	if Input.is_action_pressed("Enter"):
		if button_pressed == 'play':
			get_tree().change_scene("res://main_game.tscn")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
