extends RigidBody2D

var damage = 0.4 setget set_damage

func _on_BaddieBullet_body_entered(body) -> void:
	if body.is_in_group("Player"):
		CombatSignalController.emit_signal("damage_player", damage)

	call_deferred("free")

func set_damage(d: float) -> void:
	damage = d
