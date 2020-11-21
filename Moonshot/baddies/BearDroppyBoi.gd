extends KinematicBody2D

onready var baddie: Baddie = load("res://baddies/Baddie.gd").new()
onready var Laser = $BaddieLaserPointer
onready var Fade: Fade = $Fade

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

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")

	baddie.set_properties({
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

	Fade.set_fade_speed(0.05)
	Fade.set_fade_factor(0.3)
	Fade.set_sprite($AnimatedSprite)
	Fade.set_tree(get_tree())
	Fade.set_on_fade_out_finish(funcref(self, "on_end"))

func _physics_process(delta) -> void:
	if baddie.has_died():
		if !Fade.is_fading:
			Fade.fade_out()
			$AnimatedSprite.stop()
			return
		return

	var collided_with_player: bool = baddie.check_player_colision()
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

		baddie.patch({
			"gravity": -baddie.gravity * 20,
			"speed": 600,
			"hp": HP_MAX / ARMOR
		})
		self.rotate(PI)
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h

	baddie.move(delta)

func change_direction() -> void:
	if !baddie.has_died():
		facing *= -1
		baddie.flip_sprite_horizontal()
		var cast = $JumpCast.get_cast_to()
		$JumpCast.set_cast_to(Vector2(-1*cast.x, cast.y))
		baddie.set("direction", baddie.change_direction())
		$FrontRayCast.async_change_direction()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !baddie.has_died():
		baddie.on_hit(damage)

func on_end() -> void:
	call_deferred("free")

