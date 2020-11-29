tool
extends KinematicBody2D
class_name TankyBoi

export(bool)  var swap_dir  setget swap_dir

const COOL_DOWN_COLOR: Color = Color(1, 1, 1, 1)
const COOL_DOWN_SPEED: int = 100
const COOL_DOWN_PERIOD: int = 2
const RUSH_COLOR: Color = Color(1, 0.701961, 0, 1)
const RUSH_SPEED: int = COOL_DOWN_SPEED * 9

var attributes: Attributes = preload("res://baddies/Attributes.gd").new()
var cool_down = false
var is_rushing = false

const Animations := {
	"RUSH": "rush",
	"SPRINT": "sprint"
}

func swap_dir(value = null) -> void:
	if !Engine.is_editor_hint(): return
	change_direction()

func _init() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	attributes.set_properties({
		"body": self,
		"animation": Animations.RUSH,
		"speed": COOL_DOWN_SPEED,
		"inital_hp": 20.0,
		"gravity": 10,
		"damage_to_player": 0.2,
		"floor_vector": Vector2(0, -1),
		"should_damage_on_collision": true
	})
	
func _ready():
	if Engine.is_editor_hint(): return
	attributes.set_sprite($AnimatedSprite)

func _physics_process(delta) -> void:
	if Engine.is_editor_hint(): return

	var tree: SceneTree = get_tree()
	if attributes._has_died() || Utils.is_nil(tree):
		return

	var collided_with_player: bool = attributes._check_player_colision()
	var falling_off_ledge: bool = $FrontRayCast.is_colliding() == false || $RearRayCast.is_colliding() == false
	var collided_with_wall: bool = is_on_wall() && !collided_with_player
	
	if (falling_off_ledge || collided_with_wall) && !$FrontRayCast.is_turning:
		change_direction()

	if !cool_down:
		cool_down = true
		is_rushing = true
		yield(tree.create_timer(COOL_DOWN_PERIOD), "timeout")
		$AnimatedSprite.modulate = RUSH_COLOR
		$AnimatedSprite.play(Animations.SPRINT)

		attributes.fade.set_fade_speed(0.02)
		attributes.fade.set_fade_factor(0.2)
		attributes.speed = RUSH_SPEED
		attributes.fade.oscillate([attributes.fade.R], 0.3, 4)

		yield(tree.create_timer(COOL_DOWN_PERIOD), "timeout")
		$AnimatedSprite.modulate = COOL_DOWN_COLOR
		$AnimatedSprite.play(Animations.RUSH)
		attributes.speed = COOL_DOWN_SPEED
		is_rushing = false
		cool_down = false

	if !is_rushing:
		$AnimatedSprite.play(Animations.RUSH)
	attributes.velocity.x = attributes.speed * attributes.direction
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
