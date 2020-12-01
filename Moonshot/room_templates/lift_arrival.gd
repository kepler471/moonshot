extends Node2D

onready var ButtonPanel = $LiftButton
onready var Doors = $LiftDoors
onready var dialog_box = $DialogBox

func _ready():
	dialog_box.set_visible(false)
	activate_lift()
	


func activate_lift():
	Doors.z_index = 3
	ButtonPanel.z_index = 3
	$LiftButton.change_texture("red")
	Doors.play()
	


func _on_LiftDoors_animation_finished():
	if Doors.get_animation() == "Open":
		Doors.z_index = 0
		ButtonPanel.z_index = 0
		Doors.set_animation("Close")
		Doors.play()
		dialog_box.assign_script("level_entry_story")
		dialog_box.set_visible(true)
		dialog_box.start_dialog()

