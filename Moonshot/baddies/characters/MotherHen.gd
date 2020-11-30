tool
extends KinematicBody2D
class_name MotherHen

export(bool)  var swap_direction  setget swap_dir

var attributes: Attributes = preload("res://baddies/Attributes.gd").new()
onready var spawner: BaddieSpawner = $BaddieSpawner
const DEFAULT_CHILD_COUNT = 10

const Animations = {
	"FLOAT": "float"
}


func swap_dir(_value = null) -> void:
	if !Engine.is_editor_hint(): return
	change_direction()


func _init() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	attributes.set_properties({
		"body": self,
		"animation": Animations.FLOAT,
		"speed": 0,
		"inital_hp": 1.0,
		"gravity": 1,
		"damage_to_player": 0.05,
		"floor_vector": Vector2(0, -1),
		"should_damage_on_collision": true
	})


func _ready():
	if Engine.is_editor_hint(): return
	print("mother hen dir ::: ", $SpawnDirection.get_cast_to().x)
	attributes.set_sprite($AnimatedSprite)
	spawner.set_direction($SpawnDirection.get_cast_to().x)
	spawner.spawn_randomly()
	
	# Setup mother kill animation
	var center = $Death/ColorRect.get_viewport_rect().size / 2
	$Death/ColorRect.set_visible(false)
	$Death/Panel1.set_visible(false)
	$Death/Panel2.set_visible(false)
	$Death/Panel1.set_position(center)
	$Death/Panel2.set_position(center)


func _physics_process(delta):
	if Engine.is_editor_hint(): return

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
	get_parent().get_tree().paused = true
	
	$Death/ColorRect.set_visible(true)
	yield(get_tree().create_timer(0.5), "timeout")
	$Death/Panel1.set_visible(true)
	$Death/Panel1.play("default")
	yield(get_tree().create_timer(1.5), "timeout")
	$Death/Panel1.set_visible(false)
	$Death/Panel1.stop()
	$Death/Panel2.set_visible(true)
	$Death/Panel2.play("default")
	yield(get_tree().create_timer(1.5), "timeout")
	$Death/Panel2.set_visible(false)
	$Death/Panel2.stop()
	$Death/ColorRect.set_visible(false)
	get_parent().get_tree().paused = false
	if get_parent().get_node("ExitLift"):
		get_parent().get_node("ExitLift").activate_lift()
	on_end()
	

func on_end() -> void:
	call_deferred("free")

func change_direction() -> void:
	$SpawnDirection.set_cast_to(-$SpawnDirection.get_cast_to())
	attributes._change_direction()
