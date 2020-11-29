extends Area2D

onready var ButtonPanel = $LiftButton
onready var Doors = $LiftDoors

var lift_active = false
var entered_body

func _ready():
	activate_lift()

func _input(event):
	if Input.is_action_pressed("enter") and entered_body and lift_active:
		$PlayerContainer.get_node("CollisionBox").set_disabled(false)
		Doors.play()

func next_level():
	var main_scene = get_tree().get_root().get_node('MainGame')
	main_scene.go_up_level()

func activate_lift():
	lift_active = true
	$LiftButton.change_texture("green")

func _on_Node2D_body_entered(body):
	if body.is_in_group('Player') and lift_active:
		$LiftButton.change_texture("on")
		entered_body = body
		
func _on_Node2D_body_exited(body):
	if body.is_in_group('Player') and lift_active:
		$LiftButton.change_texture("green")
		entered_body = null


func _on_LiftDoors_animation_finished():
	
	if Doors.get_animation() == "Open":
		Doors.z_index = 3
		ButtonPanel.z_index = 3
		Doors.set_animation("Close")
		Doors.play()

	elif Doors.get_animation() == "Close":
		if get_tree().get_current_scene().MAIN_GAME == true:
			next_level()
