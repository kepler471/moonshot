extends RayCast2D
class_name TurningHack

var is_turning: bool = false

func async_change_direction() -> void:
	is_turning = true
	yield(get_tree().create_timer(0.2), "timeout")
	is_turning = false
