extends KinematicBody2D

var Baddie = load("res://baddies/Baddie.gd").new()
onready var FadeOut: FadeOut = $FadeOut

const GRAVITY := 0
const ACCELERATION := 25
const HP_MAX := 0.5
const FLOOR := Vector2(0, -1)
const DAMAGE_TO_PLAYER := 0.33
const BOUNCE_FACTOR := 0.7

var speed := 380
var velocity := Vector2()
var bounce := 0.7;
const Animations := {
	"FLY": "fly"
}

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	Baddie.set_body(self)
	Baddie.set_gravity(GRAVITY)
	Baddie.set_init_hp(HP_MAX)
	Baddie.set_move_animation(Animations.FLY)
	Baddie.set_damage(DAMAGE_TO_PLAYER)

	FadeOut.set_fade_speed(0.05)
	FadeOut.set_fade_decrementer(0.3)
	FadeOut.set_sprite($AnimatedSprite)
	FadeOut.set_tree(get_tree())
	FadeOut.set_on_end(funcref(self, "on_end"))

func _process(delta) -> void:
	if Baddie == null:
		if !FadeOut.is_fading:
			FadeOut.fade()
		return

	velocity.x = speed * Baddie.direction
	$AnimatedSprite.play()
	velocity.y += bounce

	velocity = move_and_slide(velocity, FLOOR)
	Baddie.check_player_colision(true)

	if is_on_ceiling():
		bounce = BOUNCE_FACTOR
		speed += ACCELERATION
		velocity.y += 100

	if is_on_floor():
		bounce = -BOUNCE_FACTOR
		speed += ACCELERATION
		velocity.y -= 100

	if is_on_wall():
		change_direction()

func change_direction():
	if has_baddie():
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
		Baddie.direction = Baddie.change_direction()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && has_baddie():
		change_direction()
		Baddie.on_hit(damage)

func on_end() -> void:
	call_deferred("free")

func has_baddie() -> bool:
	return Baddie != null
