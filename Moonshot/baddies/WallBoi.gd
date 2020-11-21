extends KinematicBody2D

onready var baddie: Baddie = load("res://baddies/Baddie.gd").new()
onready var Laser = $BaddieLaserPointer
onready var Fade: Fade = $Fade

const GRAVITY := -0
const SPEED := 230
const HP_MAX := 1.0
const FLOOR := Vector2(0, -1)
const DAMAGE_TO_PLAYER := 0.02
const Animations := {
	"RUSH": "rush"
}

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	baddie.set_properties({
		"inital_hp": HP_MAX,
		"gravity": GRAVITY,
		"speed": SPEED,
		"sprite": $AnimatedSprite,
		"velocity": Vector2(),
		"body": self,
		"floor_vector": FLOOR,
		"animation": Animations.RUSH,
		"damage_to_player": DAMAGE_TO_PLAYER
	})

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
	if baddie.has_died():
		if !Fade.is_fading:
			Fade.fade_out()
			$AnimatedSprite.stop()
		return

	var collided_with_player: bool = baddie.check_player_colision()
	var falling_off_ledge: bool = $FrontRayCast.is_colliding() == false || $RearRayCast.is_colliding() == false
	var collided_with_wall: bool = (is_on_floor() || is_on_ceiling()) && !collided_with_player
	
	if (falling_off_ledge || collided_with_wall) && !$FrontRayCast.is_turning:
		change_direction()

	baddie.velocity.y = baddie.speed * baddie.direction
	baddie.velocity.x += baddie.velocity.x + baddie.gravity

	baddie.velocity = move_and_slide(baddie.velocity, baddie.floor_vector)

func change_direction() -> void:
	baddie.flip_sprite_horizontal()
	baddie.set("direction", baddie.change_direction())
	$FrontRayCast.async_change_direction()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !baddie.has_died():
		baddie.on_hit(damage)

func on_end() -> void:
	call_deferred("free")
