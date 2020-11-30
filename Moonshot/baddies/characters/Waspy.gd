tool
extends KinematicBody2D
class_name Waspy

export(bool)  var swap_direction  setget swap_dir

var attributes: Attributes = preload("res://baddies/Attributes.gd").new()
var beam = load("res://baddies/BaddieLaser/Blob.tscn")
var phi : float # angle between self and target
var theta : float # global rotation
var turn_max := PI
var max_speed := 9.0
var acceleration := 40.0
var dir : float
var coll
var facing = 1
var is_diving := false
var dive_counter : int = 1
const wobble_rate : float = 4.0
const wobble_amp : float = 20.0
onready var hover_height = $RayCast2D.get_cast_to() + $RayCast2D.get_position()
var target : Vector2

func _get_configuration_warning() -> String:
	return "" if is_z_relative() else "%s requires relative z index enabled" % name


func swap_dir(_value = null) -> void:
	if !Engine.is_editor_hint(): return
	change_direction()


func _init() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	attributes.set_properties({
		"body": self,
		"direction": attributes.Direction.RIGHT,
		"inital_hp": 3,
		"gravity": 0,
		"speed": max_speed,
		"velocity": Vector2()
	})


func _ready():
	if Engine.is_editor_hint(): return
	attributes.set_sprite($AnimatedSprite)
	$AnimatedSprite.play()
	set_z_index(3)
	$CollisionShape2D.set_deferred("disabled", false)


func _physics_process(delta) -> void:
	if Engine.is_editor_hint(): return
	
	target = Utils.Player.get_node("TurnAxis").get_global_position()

	if is_diving:
		if dive_counter % 120 == 0:
			dive_counter += 1
			CombatSignalController.emit_signal("damage_player", attributes.damage_to_player, position)
			return
			
		dive_counter += 1
		set_global_position(target - hover_height)

		# Physics for wobble and charging/descent to player
		$CollisionShape2D.set_position(Vector2(
			wobble_amp*sin(2*PI*wobble_rate*float(dive_counter%120)/120),
			((clamp(float(dive_counter),0,120)/120))*hover_height.y)
		)
		$AnimatedSprite.set_position(Vector2(
			wobble_amp*sin(2*PI*wobble_rate*float(dive_counter%120)/120),
			((clamp(float(dive_counter),0,120)/120))*hover_height.y)
		)

	elif not is_diving:
		theta = get_global_rotation()
		phi = get_global_position().angle_to_point(target - hover_height - $RayCast2D.get_position() * Vector2(1,0)) - theta

		attributes.velocity += Vector2.LEFT.rotated(theta + phi).normalized() * acceleration * delta
		attributes.velocity = attributes.velocity.clamped(max_speed)
		coll = attributes.body.move_and_collide(attributes.velocity)
	
		if $RayCast2D.is_colliding() or $RayCast2D2.is_colliding() or $RayCast2D3.is_colliding():
			attributes.velocity = Vector2.ZERO
			is_diving = true
			attack()
			return

		dir = Utils.Player.get_global_position().x - get_global_position().x
		
		if sign(dir) == 0:
			pass
		elif sign(dir) != sign(facing):
			change_direction()


func change_direction() -> void:
	facing *= -1
# warning-ignore:return_value_discarded
	attributes._change_direction()
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h

func attack():
	attributes._flash()

# warning-ignore:shadowed_variable
func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !attributes._has_died():
		attributes._on_hit(damage, global_position)


func on_end() -> void:
	call_deferred("free")
