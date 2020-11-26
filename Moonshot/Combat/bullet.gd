extends RigidBody2D

signal animation_finished

onready var animation: AnimationPlayer = $AnimatedSprite/AnimationPlayer
var f_mag = 800
var damage = 0.4


func _ready():
	apply_impulse(Vector2(100,100).rotated(rotation), Vector2(f_mag, 0).rotated(rotation))
	animation.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")


func _on_any_body_entered(body):
	if body.is_in_group("Baddies"):
		CombatSignalController.emit_signal("damage_baddie",body.get_instance_id(), damage)

	if !body.is_in_group("Player"):
		_destroy()
		_play_hit_animation()


func _destroy():
	get_node("CollisionShape2D").set_deferred("disabled", true)
	set_linear_velocity(Vector2.ZERO)


func _play_hit_animation():
	animation.play("hit")


func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	emit_signal("animation_finished", anim_name)
	if anim_name == "hit":
		call_deferred("free")
