extends KinematicBody2D
class_name GhostyBoi

var attributes: Attributes = preload("res://baddies/Attributes.gd").new()
var beam = load("res://baddies/BaddieLaser/Blob.tscn")
var phi : float # angle between self and target
var theta : float # global rotation
var turn_max := PI
var max_speed := 2.0
var acceleration := 6.0
var dir : float
var coll
var damage := 0.02
var cooldown := false
var cooldown_timer :=  0.1
var facing = 1


func _get_configuration_warning() -> String:
	return "" if is_z_relative() else "%s requires relative z index enabled" % name


func _init() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")

	attributes.set_properties({
		"body": self,
		"direction": attributes.Direction.RIGHT,
		"inital_hp": 10,
		"gravity": 0,
		"speed": max_speed,
		"velocity": Vector2(),
	})


func _ready():
	attributes.set_sprite($AnimatedSprite)
	$AnimatedSprite.play()
	set_z_index(3)


func _physics_process(delta) -> void:
	theta = get_global_rotation()
	phi = get_global_position().angle_to_point(Utils.Player.get_node("TurnAxis").get_global_position() - 0.75 * $RayCast2D.get_cast_to()) - theta

	attributes.velocity += Vector2.LEFT.rotated(theta + phi).normalized() * acceleration * delta
	attributes.velocity = attributes.velocity.clamped(max_speed)
	coll = attributes.body.move_and_collide(attributes.velocity)
	
	if $RayCast2D.is_colliding() and not cooldown:
		drop_blob()

	dir = Utils.Player.get_global_position().x - get_global_position().x
	
	if sign(dir) == 0:
		pass
	elif sign(dir) != sign(facing):
		flip_body()


func flip_body() -> void:
	facing *= -1
	attributes._change_direction()
	$RayCast2D.set_rotation(-$RayCast2D.get_rotation())
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	$AnimatedSprite.set_offset($AnimatedSprite.get_offset() * Vector2(-1,1))
	$CollisionShape2D.set_position($CollisionShape2D.get_position() * Vector2(-1,1))


func drop_blob() -> void:
	var shot = beam.instance()
	shot.set_damage(damage)
	get_tree().get_root().add_child(shot)
	shot.set_global_position(get_global_position())
	cooldown = true
	yield(get_tree().create_timer(cooldown_timer), "timeout")
	cooldown = false


func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !attributes._has_died():
		attributes._on_hit(damage, global_position)


func on_end() -> void:
	call_deferred("free")
