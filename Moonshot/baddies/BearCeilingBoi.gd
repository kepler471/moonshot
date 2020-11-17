extends KinematicBody2D

var Baddie = load("res://baddies/Baddie.gd").new()
onready var Laser = $BaddieLaserPointer

const GRAVITY := -10
const SPEED := 230
const HP_MAX := 1.0
const FLOOR := Vector2(0, -1)
const DAMAGE_TO_PLAYER := 0.02
const Animations := {
	"RUSH": "rush"
}

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	Baddie.set_sprite($AnimatedSprite)
	Baddie.set_body(self)
	Baddie.set_gravity(GRAVITY)
	Baddie.set_speed(SPEED)
	Baddie.set_init_hp(HP_MAX)
	Baddie.set_move_animation(Animations.RUSH)
	Baddie.set_damage(DAMAGE_TO_PLAYER)
	
	Laser.set_upper_shot_frequency(1)
	Laser.set_shot_speed(500)
	Laser.shoot_randomly()

func _process(delta) -> void:
	if Baddie == null:
		call_deferred("free")
		return

	var collided_with_player: bool = Baddie.check_player_colision(true)
	var falling_off_ledge: bool = $FrontRayCast.is_colliding() == false || $RearRayCast.is_colliding() == false
	var collided_with_wall: bool = is_on_wall() && !collided_with_player
	
	if falling_off_ledge || collided_with_wall:
		change_direction()
		
	Baddie.move(delta)

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id():
		Baddie.on_hit(damage)

func change_direction() -> void:
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	Baddie.direction = Baddie.change_direction()

