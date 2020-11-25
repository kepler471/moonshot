extends RigidBody2D

var f_mag = 800
var damage = 0.4

func _ready():
	apply_impulse(Vector2(100,100).rotated(rotation), Vector2(f_mag, 0).rotated(rotation))

func _on_any_body_entered(body):
	if body.is_in_group("Baddies"):
		CombatSignalController.emit_signal("damage_baddie",body.get_instance_id(), damage)

	if !body.is_in_group("Player"):
		get_node("CollisionShape2D").set_deferred("disabled", true)
		call_deferred("free")
		


