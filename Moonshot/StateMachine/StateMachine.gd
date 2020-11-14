extends Node
class_name StateMachine
# Generic State Machine. Initializes states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the active state.


export var initial_state := NodePath()

onready var state: State = get_node(initial_state) setget set_state
onready var _state_name := state.name
var _animation_name


func _init() -> void:
	add_to_group("state_machine")


func _ready() -> void:
	yield(owner, "ready")
	state.enter()


func _unhandled_input(event: InputEvent) -> void:
	state.unhandled_input(event)


func _physics_process(delta: float) -> void:
	state.physics_process(delta)


func transition_to(target_state_path: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		return

	var target_state := get_node(target_state_path)
	set_animation_name(target_state)
	state.exit()
	self.state = target_state
	state.enter(msg)

func set_animation_name(value: State) -> void:
	_animation_name = value.name.to_lower()

func get_animation_name() -> String:
	return _animation_name

func set_state(value: State) -> void:
	state = value
	_state_name = state.name
