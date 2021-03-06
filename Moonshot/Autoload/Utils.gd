extends Node

var PlayerArsenal = load("res://player/PlayerArsenal.gd")
# Globally accessible utils functionality
var player_stats = load('res://Combat/Stats.tscn').instance()
var player_arsenal = PlayerArsenal.new()
var Player = load("res://player/player.tscn").instance()
const IS_DEBUG: bool = false


func reset_player():
	Player.queue_free()
	Player = load("res://player/player.tscn").instance()

func restart_game():
	Player.queue_free()
	player_stats = load('res://Combat/Stats.tscn').instance()
	Player = load("res://player/player.tscn").instance()
	


	
# Returns the direction in which the player is aiming with the stick
static func get_aim_joystick_direction() -> Vector2:
	return get_aim_joystick_strength().normalized()


# Returns the strength of the XY input with the joystick used for aiming,
# each axis being a value between 0 and 1
# Adds a circular deadzone, as Godot's built-in system is per-axis,
# creating a rectangular deadzone on the joystick
static func get_aim_joystick_strength() -> Vector2:
	var deadzone_radius := 0.5
	var input_strength := Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	)
	return input_strength if input_strength.length() > deadzone_radius else Vector2.ZERO

# Checks if two numbers are approximately equal
static func is_equal_approx(a: float, b: float, cmp_epsilon: float = 1e-5) -> bool:
	var tolerance := cmp_epsilon * abs(a)
	if tolerance < cmp_epsilon:
		tolerance = cmp_epsilon
	return abs(a - b) < tolerance

# returns a new Dictionary, immutable.
static func merge_dictionary(target = {}, patch: Dictionary = {}) -> Dictionary:
	var new_dictionary: Dictionary = {}

	for key in target:
		new_dictionary[key] = target[key]

	for key in patch:
		new_dictionary[key] = patch[key]

	return new_dictionary;

static func is_nil(argv) -> bool:
	return argv == null
	
static func sloooooowdown(tween: Tween, duration: float) -> void:
	tween.interpolate_property(Engine, "time_scale", 1, 0.1, duration, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()

static func speeeeeeeedup(tween: Tween, duration: float) -> void:
	tween.interpolate_property(Engine, "time_scale", 0.1, 1, duration, Tween.TRANS_LINEAR)
	tween.start()

static func zoomin(tween: Tween, _cam: Camera2D, duration: float) -> void:
	tween.interpolate_property(_cam, "zoom", Vector2(1, 1), Vector2(0.4, 0.4), duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
