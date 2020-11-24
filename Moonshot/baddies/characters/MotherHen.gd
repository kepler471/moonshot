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
		"inital_hp": 40.0,
		"gravity": 1,
		"damage_to_player": 0.2,
		"floor_vector": Vector2(0, -1),
		"should_damge_on_collision": true
	})
	
func _ready():
	attributes.set_sprite($AnimatedSprite)
	spawner.spawn_randomly()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id() && !attributes._has_died():
		spawner.spawn_randomly()
		attributes._on_hit(damage, global_position)

func on_end() -> void:
	call_deferred("free")
