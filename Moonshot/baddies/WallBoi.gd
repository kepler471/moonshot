extends KinematicBody2D

var Baddie = load("res://baddies/Baddie.gd").new()
onready var Laser = $BaddieLaserPointer
onready var Fade: Fade = $Fade

const GRAVITY := -0
const SPEED := 230
const HP_MAX := 1.0
const FLOOR := Vector2(0, -1)
const DAMAGE_TO_PLAYER := 0.02
const Animations := {
	"CRAWL": "crawl"
}

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	Baddie.set_sprite($AnimatedSprite)
	Baddie.set_body(self)
	Baddie.set_gravity(GRAVITY)
	Baddie.set_speed(SPEED)
	Baddie.set_init_hp(HP_MAX)
	Baddie.set_move_animation(Animations.CRAWL)
	Baddie.set_damage(DAMAGE_TO_PLAYER)
	
	Laser.set_upper_shot_frequency(1)
	Laser.set_shot_speed(500)
	Laser.shoot_randomly()
	Laser.set_damage(0.4)

	Fade.set_fade_speed(0.05)
	Fade.set_fade_factor(0.3)
	Fade.set_sprite($AnimatedSprite)
	Fade.set_tree(get_tree())
	Fade.set_on_fade_out_finish(funcref(self, "on_end"))

func _process(delta) -> void:
	if Baddie == null:
		if !Fade.is_fading:
			Fade.fade_out()
			$AnimatedSprite.stop()
		return

	var collided_with_player: bool = Baddie.check_player_colision(true)
	var falling_off_ledge: bool = $FrontRayCast.is_colliding() == false || $RearRayCast.is_colliding() == false
	var collided_with_wall: bool = (is_on_floor() || is_on_ceiling())&& !collided_with_player
	
	if (falling_off_ledge || collided_with_wall) && !$FrontRayCast.is_turning:
		change_direction()
		
	Baddie.velocity.y = Baddie.speed * Baddie.direction
	$AnimatedSprite.play(Animations.CRAWL)
	Baddie.velocity.x += Baddie.gravity

	Baddie.velocity = move_and_slide(Baddie.velocity, FLOOR)

func change_direction() -> void:
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	Baddie.direction = Baddie.change_direction()
	$FrontRayCast.async_change_direction()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && has_baddie():
		Baddie.on_hit(damage)

func on_end() -> void:
	call_deferred("free")

func has_baddie() -> bool:
	return Baddie != null
