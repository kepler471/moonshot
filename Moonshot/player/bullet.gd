extends RigidBody2D

class_name Bullet

var bullet = load("res://player/bullet.tscn")
var f_mag = 500

func _ready():
	apply_impulse(Vector2(100,100).rotated(rotation), Vector2(f_mag, 0).rotated(rotation))

func _on_any_body_entered(body):
	print(body)
	queue_free()
