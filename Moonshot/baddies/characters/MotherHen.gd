extends KinematicBody2D
class_name MotherHen

var attributes: Attributes = preload("res://baddies/Attributes.gd").new()
onready var spawner: BaddieSpawner = $BaddieSpawner
const DEFAULT_CHILD_COUNT = 10

const Animations = {
	"FLOAT": "float"
}

func _init() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	attributes.set_properties({
		"body": self,
		"animation": Animations.FLOAT,
		"speed": 0,
		"inital_hp": 10.0,
		"gravity": 1,
		"damage_to_player": 0.05,
		"floor_vector": Vector2(0, -1),
		"should_damage_on_collision": true
	})
	
func _ready():
	attributes.set_sprite($AnimatedSprite)
	spawner.spawn_randomly()
	
func _physics_process(delta):
	move_and_slide(Vector2.ZERO)
	var _q = attributes._check_player_colision()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !attributes._has_died():
		spawner.spawn_randomly()
		attributes.hp -= damage
		attributes._flash()
		if attributes.hp <= 0:
			death_transition()

func death_transition() -> void:
	attributes.set_properties({"body": self, "should_damage_on_collision": false})
	on_end()

func on_end() -> void:
	attributes.fade.set_fade_speed(0.05)
	attributes.fade.set_fade_factor(0.3)
	attributes.dead = true
	attributes.fade.fade_out()
