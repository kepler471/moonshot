extends KinematicBody2D
class_name GhostyBoi

var attributes: Attributes = preload("res://baddies/Attributes.gd").new()
var beam = load("res://baddies/BaddieLaser/Blob.tscn")
var phi : float		# angle between self and target
var theta : float	# global rotation
var turn_max := PI
var max_speed := 2.0
var acceleration := 6.0
var coll
var damage := 0.02
var cooldown := false
var cooldown_timer :=  0.2


func _get_configuration_warning() -> String:
	return "" if is_z_relative() else "%s requires relative z index enabled" % name


func _init() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")

	attributes.set_properties({
		"body": self,
		"direction": attributes.Direction.RIGHT,
		"inital_hp": 5,
		"gravity": 0,
		"speed": max_speed,
		"sprite": $AnimatedSprite,
		"velocity": Vector2(),
		"damage_to_player": 0.2,
		"should_damge_on_collision": false
	})


func _ready():
	attributes.set_sprite($AnimatedSprite)
	$AnimatedSprite.play()
	set_z_index(3)


func _physics_process(delta) -> void:
	theta = get_global_rotation()
	phi = get_global_position().angle_to_point(Utils.Player.get_node("TurnAxis").get_global_position() - $RayCast2D.get_cast_to()) - theta

	attributes.velocity += Vector2.LEFT.rotated(theta + phi).normalized() * acceleration * delta
	attributes.velocity = attributes.velocity.clamped(max_speed)
	coll = attributes.body.move_and_collide(attributes.velocity)
	
	if $RayCast2D.is_colliding() and not cooldown:
		drop_blob()


#func on_hit(instance_id, damage) -> void:
#	if instance_id == self.get_instance_id() && !attributes._has_died():
#		change_direction()
#		attributes._on_hit(damage, global_position)

func drop_blob() -> void:
	var shot = beam.instance()
	shot.set_damage(damage)
	get_tree().get_root().add_child(shot)
	shot.set_global_position(get_global_position())
	cooldown = true
	yield(get_tree().create_timer(cooldown_timer), "timeout")
	cooldown = false
