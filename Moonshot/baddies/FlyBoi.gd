extends KinematicBody2D

onready var baddie: Baddie = load("res://baddies/Baddie.gd").new()
onready var Fade: Fade = $Fade

const GRAVITY := 0
const ACCELERATION := 25
const HP_MAX := 0.5
const BOUNCE_FACTOR := 0.7

var _properties: Dictionary = {
	"body": self,
	"inital_hp": HP_MAX,
	"gravity": 0,
	"speed": 300,
	"floor_vector": Vector2(0, -1),
	"sprite": $AnimatedSprite,
	"velocity": Vector2(),
	"damage_to_player": 0.33,
	"should_damge_on_collision": true
}

var bounce := 0.7;
const Animations := {
	"RUSH": "rush"
}

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	
	baddie.set_properties(_properties)

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

	baddie.velocity.x = baddie.speed * baddie.direction
	$AnimatedSprite.play()
	baddie.velocity.y = bounce

	move_and_slide(baddie.velocity, baddie.get("floor_vector"))
	baddie.check_player_colision()

	if is_on_ceiling():
		bounce = BOUNCE_FACTOR
		baddie.set("speed", baddie.speed + ACCELERATION)
		baddie.velocity.y += 100

	if is_on_floor():
		bounce -= BOUNCE_FACTOR
		baddie.set("speed", baddie.speed + ACCELERATION)
		baddie.velocity.y -= 100

	if is_on_wall():
		change_direction()

func change_direction():
	if !baddie.has_died():
		baddie.flip_sprite_horizontal()
		baddie.set("direction", baddie.change_direction())

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !baddie.has_died():
		change_direction()
		baddie.on_hit(damage)

func on_end() -> void:
	call_deferred("free")

