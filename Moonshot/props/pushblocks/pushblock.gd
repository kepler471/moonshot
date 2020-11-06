extends KinematicBody2D

var vel = Vector2()
#var old_ret_len : float
var initial_position := Vector2()

func _ready():
	initial_position = position

func _physics_process(delta):
	if not gamestate.state.can_push:
		position = initial_position
	else:
		if not $RayCast2D.is_colliding():
			vel.y = min( vel.y + 400 * delta, 160 )
			var _ret = move_and_slide( vel, Vector2.UP )
		else:
			vel.y = 0


func _on_check_player_body_exited(_body):
#	position = position.round()
	#print("Y")
	pass
