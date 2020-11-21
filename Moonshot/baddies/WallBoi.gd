extends KinematicBody2D

onready var attributes: Attributes = $Attributes
onready var Laser = $BaddieLaserPointer

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
	attributes.set_properties({
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

func _process(delta) -> void:
	if attributes._has_died():
		return

	var collided_with_player: bool = attributes._check_player_colision()
	var falling_off_ledge: bool = $FrontRayCast.is_colliding() == false || $RearRayCast.is_colliding() == false
	var collided_with_wall: bool = (is_on_floor() || is_on_ceiling()) && !collided_with_player
	
	if (falling_off_ledge || collided_with_wall) && !$FrontRayCast.is_turning:
		change_direction()

	attributes.velocity.y = attributes.speed * attributes.direction
	attributes.velocity.x += attributes.velocity.x + attributes.gravity

	attributes.velocity = move_and_slide(attributes.velocity, attributes.floor_vector)

func change_direction() -> void:
	attributes.flip_sprite_horizontal()
	attributes.set("direction", attributes._change_direction())
	$FrontRayCast.async_change_direction()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !attributes._has_died():
		attributes._on_hit(damage)

func on_end() -> void:
	call_deferred("free")
