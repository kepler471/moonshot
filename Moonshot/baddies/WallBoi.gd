extends KinematicBody2D

var Baddie = load("res://baddies/Baddie.gd").new()

onready var Laser = $BaddieLaserPointer
const GRAVITY := 0
const SPEED := 230
const HP_MAX := 0.4
const FLOOR := Vector2(0, -1)
const DAMAGE_TO_PLAYER := 0.02
const Animations := {
	"CRAWL": "crawl"
}
var velocity := Vector2()

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	Baddie.set_body(self)
	Baddie.set_init_hp(HP_MAX)
	Baddie.set_damage(DAMAGE_TO_PLAYER)
	
	Laser.set_upper_shot_frequency(1)
	Laser.set_shot_speed(500)
	Laser.shoot_randomly()

func _physics_process(delta) -> void:
	if Baddie == null:
		call_deferred("free")
		return

	Baddie.check_player_colision(true)
	velocity.x = SPEED * Baddie.direction
	$AnimatedSprite.play()
	detect_ray_cast_collision()
	velocity = move_and_slide_with_snap(velocity, FLOOR) 

func detect_ray_cast_collision() -> void:
	var left_collision: bool = $RayCastLeft.is_colliding()
	var top_collision: bool = $RayCastTop.is_colliding()
	var bottom_collision: bool = $RayCastBottom.is_colliding()
	var right_collision: bool = $RayCastRight.is_colliding()
	var no_collision: bool = !left_collision && !right_collision && !bottom_collision && !top_collision

	if no_collision:
		set_animated_sprite_rotation(0)
		velocity.y += 10

	if top_collision && left_collision:
		velocity.y += 80

	if top_collision && right_collision:
		set_animated_sprite_rotation(180)
		change_direction()
		velocity.x *= Baddie.direction

	if bottom_collision && left_collision:
		set_animated_sprite_rotation(0)
		velocity.x *= Baddie.direction
		change_direction()
		
	if bottom_collision && right_collision:
		set_animated_sprite_rotation(180)
		velocity.y -= 10

	if top_collision:
		set_animated_sprite_rotation(180)
		
	if bottom_collision:
		set_animated_sprite_rotation(0)

	if right_collision:
		set_animated_sprite_rotation(270)
		velocity.y -= 15

	if left_collision:
		set_animated_sprite_rotation(90)
		velocity.y += 15

func set_animated_sprite_rotation(rotation: float) -> void:
	$AnimatedSprite.rotation_degrees  = rotation

func change_direction() -> void:
	Baddie.direction = Baddie.change_direction()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id():
		Baddie.on_hit(damage)

