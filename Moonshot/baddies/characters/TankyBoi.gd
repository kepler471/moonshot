extends KinematicBody2D
class_name TankyBoi

const RUSH_COLOR = Color(1, 0.701961, 0, 1)
const COOL_DOWN_COLOR = Color(1, 1, 1, 1)
const COOL_DOWN_PERIOD = 2
const DEFAULT_SPEED = 100

var attributes: Attributes = preload("res://baddies/Attributes.gd").new()
var cool_down = false
var is_rushing = false
var cool_off_period = [0.5, 2.5]

const Animations := {
	"RUSH": "rush",
	"SPRINT": "sprint"
}

func _init() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	attributes.set_properties({
		"body": self,
		"animation": Animations.RUSH,
		"speed": DEFAULT_SPEED,
		"inital_hp": 20.0,
		"gravity": 10,
		"damage_to_player": 0.2,
		"floor_vector": Vector2(0, -1),
		"should_damge_on_collision": true
	})
	
func _ready():
	attributes.set_sprite($AnimatedSprite)

func _physics_process(delta) -> void:
	if attributes._has_died():
		return

	var collided_with_player: bool = attributes._check_player_colision()
	var falling_off_ledge: bool = $FrontRayCast.is_colliding() == false || $RearRayCast.is_colliding() == false
	var collided_with_wall: bool = is_on_wall() && !collided_with_player
	
	if (falling_off_ledge || collided_with_wall) && !$FrontRayCast.is_turning:
		change_direction()

	if !cool_down:
		cool_down = true
		is_rushing = true
		yield(get_tree().create_timer(COOL_DOWN_PERIOD), "timeout")
		attributes.fade.set_fade_speed(0.02)
		attributes.fade.set_fade_factor(0.2)
		$AnimatedSprite.modulate = RUSH_COLOR
		$AnimatedSprite.play(Animations.SPRINT)

		attributes.fade.occilate([attributes.fade.R], 0.3, 4)
		attributes.speed *= 9

		yield(get_tree().create_timer(COOL_DOWN_PERIOD), "timeout")
		$AnimatedSprite.modulate = COOL_DOWN_COLOR
		$AnimatedSprite.play(Animations.RUSH)
		attributes.speed = DEFAULT_SPEED
		is_rushing = false
		cool_down = false

	attributes.velocity.x = attributes.speed * attributes.direction
	if !is_rushing:
		$AnimatedSprite.play(Animations.RUSH)
	attributes.velocity.y += attributes.gravity
	attributes.velocity = move_and_slide(attributes.velocity, attributes.floor_vector)

func change_direction() -> void:
	if !attributes._has_died():
		attributes.set("direction", attributes._change_direction())
		attributes.flip_sprite_horizontal()

		$FrontRayCast.async_change_direction()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !attributes._has_died():
		attributes._on_hit(damage, global_position)

func on_end() -> void:
	call_deferred("free")
