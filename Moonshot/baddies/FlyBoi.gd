extends KinematicBody2D

var Baddie = load("res://baddies/Baddie.gd").new()
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

func _process(delta) -> void:
	if Baddie == null:
		call_deferred("free")
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

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id():
		change_direction()
		Baddie.on_hit(damage)

func change_direction():
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	Baddie.direction = Baddie.change_direction()
