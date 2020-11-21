extends Node
# Globally accessible utils functionality
var player_stats = load('res://Combat/Stats.tscn').instance()
const IS_DEBUG: bool = false

	
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

# allows deeply nested updating, mutates
static func set_in_dictionary(keys: Array, value, dictionary = {}, counter = 0) -> void:
	if keys.size() - 1 > counter:
		var key: String = keys[counter]
		if !Utils.is_nil(key):
			var current = dictionary[key]
			counter += 1
			Utils.set_in_dictionary(keys, value, current, counter)
	else:
		dictionary[keys[counter]] = value
