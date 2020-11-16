extends Node
class_name BaddieLaserController

var Bullet = load("res://baddies/BaddieLaser/BaddieBullet.tscn")

# the upper bounds: the shooting is RNG
var shot_frequency_limit: int = 5 setget set_upper_shot_frequency

func _ready():
	CombatSignalController.connect("emit_player_global_position", self, "shoot_player")

func shoot_randomly() -> void:
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "_get_player_global_position")
	timer.start(randi() % shot_frequency_limit)

func _get_player_global_position() -> void:
	CombatSignalController.emit_signal("get_player_global_position")

func set_upper_shot_frequency(f: int) -> void:
	shot_frequency_limit = f

func shoot_player(arg: Vector2) -> void:
	var shot = Bullet.instance()
	
	shot.position = get_parent().global_position
	shot.rotation = 4
	shot.look_at(arg)

	get_parent().add_child(shot)

	print(arg)
