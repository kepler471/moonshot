extends KinematicBody2D
class_name Chick

var attributes: Attributes = preload("res://baddies/Attributes.gd").new()

const Animations := {
	"RUSH": "rush"
}

func _init() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	attributes.set_properties({
		"body": self,
		"animation": Animations.RUSH,
		"speed": 230,
		"inital_hp": 1.0,
		"gravity": 50,
		"damage_to_player": 0.02,
		"floor_vector": Vector2(0, -1),
		"should_damage_on_collision": true
	})
	
func _ready():
	attributes.set_sprite($AnimatedSprite)

func _physics_process(delta) -> void:
	if attributes._has_died():
		return

	if $TriggerJump.is_colliding():
		if is_on_floor():
			attributes.velocity += (Vector2(0, -400))
			attributes._move(delta)
			return
		else:
			attributes._move(delta)
			return
		

	var collided_with_player: bool = attributes._check_player_colision()
	var falling_off_ledge: bool = $FrontRayCast.is_colliding() == false || $RearRayCast.is_colliding() == false
	var collided_with_wall: bool = is_on_wall() && !collided_with_player

	if (falling_off_ledge || collided_with_wall) && !$FrontRayCast.is_turning:
		change_direction()

	attributes._move(delta)

func change_direction() -> void:
	if !attributes._has_died():
		attributes.set("direction", attributes._change_direction())
		attributes.flip_sprite_horizontal()

		$FrontRayCast.async_change_direction()
		$TriggerJump.set_rotation(-$TriggerJump.get_rotation())

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !attributes._has_died():
		attributes._on_hit(damage, global_position)

func on_end() -> void:
	call_deferred("free")
