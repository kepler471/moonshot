extends Node2D

var time_tween
var pointA = Vector2(0,0)
var pointB = Vector2(0,600)


func _ready():	
	$Camera2D.make_current()
	move_camera()
	
func move_camera():
	var move_tween = get_node("MoveTween")
	move_tween.interpolate_property( self, "position", pointA, pointB, 30, Tween.TRANS_QUAD, Tween.EASE_OUT)
	move_tween.start()

func _input(event):
	if event.is_action_pressed("enter"):
		get_tree().change_scene("res://Menu/Menu.tscn")
