extends Node
class_name BaddieLaserController

var BaddieBullet = load("res://baddies/BaddieLaser/BaddieBullet.tscn")
var shot = null
var player_global_position: Vector2
var is_shooting = false

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

func shoot_player(player_global_position: Vector2) -> void:
	var shot = BaddieBullet.instance()

	add_child(shot)

	shot.position = get_parent().get_node("BaddieLaserPointer").global_position

	print("player_global_position", player_global_position)
	print("baddie", get_parent().global_position)
	print("nomalised", (player_global_position - get_parent().global_position).normalized())
	
	var shot_direction: Vector2 = (player_global_position - get_parent().global_position).normalized()
	shot.apply_central_impulse(shot_direction * 500)
	
	shot.rotation = PI + get_parent().get_node("BaddieLaserPointer").position.angle_to_point(player_global_position)


