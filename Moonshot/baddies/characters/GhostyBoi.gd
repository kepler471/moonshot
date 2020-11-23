extends KinematicBody2D
class_name FlyBoi

var attributes: Attributes = preload("res://baddies/Attributes.gd").new()
var phi : float		# angle between self and target
var theta : float	# global rotation
var turn_max := 0.01

const Animations := {
	"RUSH": "rush"
}


func _get_configuration_warning() -> String:
	return "" if is_z_relative() else "%s requires relative z index enabled" % name


func _init() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")

	attributes.set_properties({
		"body": self,
		"inital_hp": 5,
		"gravity": 0,
		"speed": 1,
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
	phi = get_global_position().angle_to_point(Utils.Player.get_global_position()) - get_global_rotation()
#	phi = min(abs(phi), turn_max) * sign(phi)
	attributes.velocity = attributes.speed * Vector2.LEFT.rotated(get_global_rotation() + phi)
	print(phi)
	set_global_rotation(get_global_rotation() + phi)
	attributes.body.move_and_collide(attributes.velocity)

func change_direction() -> void:
	if !attributes._has_died():
		attributes.set("direction", attributes._change_direction())
		attributes.flip_sprite_horizontal()

		$FrontRayCast.async_change_direction()

#
#func on_hit(instance_id, damage) -> void:
#	if instance_id == self.get_instance_id() && !attributes._has_died():
#		change_direction()
#		attributes._on_hit(damage, global_position)

func on_end() -> void:
	call_deferred("free")
