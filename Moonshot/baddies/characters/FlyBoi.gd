extends KinematicBody2D
class_name FlyBoi

var attributes: Attributes = preload("res://baddies/Attributes.gd").new()

const BOUNCE_FACTOR := 0.7

var bounce := 0.7;
const Animations := {
	"RUSH": "rush"
}

func _init() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	
	attributes.set_properties({
		"body": self,
		"inital_hp": 0.5,
		"gravity": 0,
		"speed": 300,
		"floor_vector": Vector2(0, -1),
		"velocity": Vector2(),
		"damage_to_player": 0.33,
		"should_damge_on_collision": true
	})

func _ready():
	attributes.set_sprite($AnimatedSprite)

func _physics_process(delta) -> void:
	if attributes._has_died():
		return

	attributes.velocity.x = attributes.speed * attributes.direction
	$AnimatedSprite.play()
	attributes.velocity.y += bounce

	attributes.velocity = move_and_slide(attributes.velocity, attributes.floor_vector)
	attributes._check_player_colision()

	if is_on_ceiling():
		bounce = BOUNCE_FACTOR
		attributes.velocity.y += 100

	if is_on_floor():
		bounce -= BOUNCE_FACTOR
		attributes.velocity.y -= 100

	if is_on_wall():
		change_direction()

func change_direction():
	if !attributes._has_died():
		attributes.flip_sprite_horizontal()
		attributes.set("direction", attributes._change_direction())

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !attributes._has_died():
		change_direction()
		attributes._on_hit(damage, global_position)

func on_end() -> void:
	call_deferred("free")

