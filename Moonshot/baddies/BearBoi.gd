extends KinematicBody2D

onready var attributes: Attributes = $Attributes

const Animations := {
	"RUSH": "rush"
}

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")

	attributes.set_properties({
		"sprite": $AnimatedSprite,
		"body": self,
		"animation": Animations.RUSH,
		"speed": 230,
		"inital_hp": 1.0,
		"gravity": 10,
		"damage_to_player": 0.02,
		"floor_vector": Vector2(0, -1),
		"should_damge_on_collision": true
	})

func _process(delta) -> void:
	if attributes._has_died():
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

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !attributes._has_died():
		attributes._on_hit(damage)

func on_end() -> void:
	call_deferred("free")
