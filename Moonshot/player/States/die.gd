extends State


var last_checkpoint: Area2D = null


func _on_Player_animation_finished(_anim_name: String) -> void:
	_state_machine.transition_to('Spawn', {last_checkpoint = last_checkpoint})


func enter(msg: Dictionary = {}) -> void:
	assert("last_checkpoint" in msg)
	last_checkpoint = msg.last_checkpoint


func exit() -> void:
	pass
