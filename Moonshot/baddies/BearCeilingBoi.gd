extends KinematicBody2D

onready var baddie: Baddie = load("res://baddies/Baddie.gd").new()
onready var Laser = $BaddieLaserPointer
onready var Fade: Fade = $Fade

const Animations := {
	"RUSH": "rush"
}

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	
	baddie.set_properties({
		"sprite": $AnimatedSprite,
		"body": self,
		"animation": Animations.RUSH,
		"speed": 230,
		"inital_hp": 1.0,
		"gravity": -10,
		"damage_to_player": 0.2,
		"floor_vector": Vector2(0, -1),
		"should_damge_on_collision": true
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
		return

	var collided_with_player: bool = baddie.check_player_colision()
	var falling_off_ledge: bool = $FrontRayCast.is_colliding() == false || $RearRayCast.is_colliding() == false
	var collided_with_wall: bool = is_on_wall() && !collided_with_player

	if (falling_off_ledge || collided_with_wall) && !$FrontRayCast.is_turning:
		change_direction()

	baddie.move(delta)

func change_direction() -> void:
	if !Utils.is_nil(baddie):
		baddie.set("direction", baddie.change_direction())
		baddie.flip_sprite_horizontal()
		$FrontRayCast.async_change_direction()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !baddie.has_died():
		baddie.on_hit(damage)

func on_end() -> void:
	call_deferred("free")

