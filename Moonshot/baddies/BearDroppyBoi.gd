extends KinematicBody2D

var Baddie = load("res://baddies/Baddie.gd").new()
onready var Laser = $BaddieLaserPointer
onready var FadeOut: FadeOut = $FadeOut

const GRAVITY := -10
const SPEED := 20
const HP_MAX := 1.0
const ARMOR := 5.0
const FLOOR := Vector2(0, -1)
const DAMAGE_TO_PLAYER := 0.02
const Animations := {
	"RUSH": "rush"
}

var facing = 1
var has_fallen = false
var in_air = false

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	Baddie.set_sprite($AnimatedSprite)
	Baddie.set_body(self)
	Baddie.set_gravity(GRAVITY)
	Baddie.set_speed(SPEED)
	Baddie.set_init_hp(HP_MAX * ARMOR)
	Baddie.set_move_animation(Animations.RUSH)
	Baddie.set_damage(DAMAGE_TO_PLAYER*5)

	FadeOut.set_fade_speed(0.05)
	FadeOut.set_fade_decrementer(0.3)
	FadeOut.set_sprite($AnimatedSprite)
	FadeOut.set_tree(get_tree())
	FadeOut.set_on_end(funcref(self, "on_end"))

func _physics_process(delta) -> void:
	if Baddie == null:
		if !FadeOut.is_fading:
			FadeOut.fade()
			return
		return

	var collided_with_player: bool = Baddie.check_player_colision(true)
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
		Baddie.set_gravity(-GRAVITY * 20)
		self.rotate(PI)
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
		Baddie.set_speed(600)
		Baddie.set_init_hp(HP_MAX / ARMOR)

	Baddie.move(delta)

func change_direction() -> void:
	if has_baddie():
		facing *= -1
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
		var cast = $JumpCast.get_cast_to()
		$JumpCast.set_cast_to(Vector2(-1*cast.x, cast.y))
		Baddie.direction = Baddie.change_direction()
		$FrontRayCast.async_change_direction()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && has_baddie():
		Baddie.on_hit(damage)

func on_end() -> void:
	call_deferred("free")

func has_baddie() -> bool:
	return Baddie != null
