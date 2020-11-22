extends KinematicBody2D
class_name BearDroppyBoi

var attributes: Attributes = preload("res://baddies/Attributes.gd").new()

onready var Laser = $BaddieLaserPointer

const HP_MAX := 1.0
const ARMOR := 5.0
const DAMAGE_TO_PLAYER := 0.2
const DAMAGE_MULTIPLIER := 5.0
const Animations := {
	"RUSH": "rush"
}

var facing = 1
var has_fallen = false
var in_air = false

func _init() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")

	attributes.set_properties({
		"sprite": $AnimatedSprite,
		"body": self,
		"animation": Animations.RUSH,
		"speed": 230,
		"inital_hp": HP_MAX * ARMOR,
		"gravity": -10,
		"damage_to_player": DAMAGE_TO_PLAYER * DAMAGE_MULTIPLIER,
		"floor_vector": Vector2(0, -1),
		"should_damge_on_collision": true
	})

func _ready():
	attributes.set_sprite($AnimatedSprite)

func _physics_process(delta) -> void:
	if attributes._has_died():

		return

	var collided_with_player: bool = attributes._check_player_colision()
	var falling_off_ledge: bool = ($FrontRayCast.is_colliding() == false || $RearRayCast.is_colliding() == false) && !$FrontRayCast.is_turning
	var collided_with_wall: bool = is_on_wall() && !collided_with_player

	if (is_on_floor() || is_on_ceiling()) && (falling_off_ledge || collided_with_wall) || collided_with_player:
		if not in_air:
			change_direction()

	if is_on_floor() && in_air && !collided_with_player:
		in_air = false
		

	if $JumpCast.is_colliding() and not has_fallen:
		has_fallen = true
		in_air = true

		attributes.patch({
			"gravity": -attributes.gravity * 20,
			"speed": 600,
			"hp": HP_MAX / ARMOR
		})
		self.rotate(PI)
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h

	attributes._move(delta)

func change_direction() -> void:
	if !attributes._has_died():
		facing *= -1
		attributes.flip_sprite_horizontal()
		var cast = $JumpCast.get_cast_to()
		$JumpCast.set_cast_to(Vector2(-1*cast.x, cast.y))
		attributes.set("direction", attributes._change_direction())
		$FrontRayCast.async_change_direction()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !attributes._has_died():
		attributes._on_hit(damage)

func on_end() -> void:
	call_deferred("free")

