extends RigidBody2D

var f_mag = 800
var damage = 0.4
var velocity = Vector2()
var player_position: Vector2
var baddie_position: Vector2

func _ready() -> void:
#	if player_position!=null && baddie_position != null:
#	apply_impulse(Vector2(100,100).rotated(rotation), Vector2(f_mag, 100).rotated(rotation))
#	apply_central_impulse((player_position - baddie_posi	tion).normalized())
	pass

func _on_BaddieBullet_body_entered(body) -> void:
	if body.is_in_group("Player"):
		CombatSignalController.emit_signal("damage_player", damage)

	call_deferred("free")
