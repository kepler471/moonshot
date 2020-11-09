extends RigidBody2D

var f_mag = 500
var damage = 20

func _ready():
	apply_impulse(Vector2(100,100).rotated(rotation), Vector2(f_mag, 0).rotated(rotation))

func _on_any_body_entered(body):
	print(body)
	get_node("CollisionShape2D").set_deferred("disabled", true)
	if body.is_in_group("Baddies"):
		body.on_hit(damage)
	call_deferred("free")
