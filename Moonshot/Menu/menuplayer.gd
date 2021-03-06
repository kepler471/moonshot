extends KinematicBody2D

# warning-ignore:unused_signal
signal hopped_off_entity

onready var state_machine: StateMachine = $StateMachine

onready var collider: CollisionShape2D = $CollisionShape2D setget ,get_collider

onready var floor_detector: RayCast2D = $FloorDetector

onready var pass_through: Area2D = $PassThrough

onready var camera: Camera2D = $Camera2D

const FLOOR_NORMAL := Vector2.UP

var is_active := true setget set_is_active
var has_teleported := false
var last_checkpoint: Area2D = null
var player_arsenal

var cooldown = false

var facing = 1
var animation_name
var playing_reverse
var safety = false
var dead = false
var priority_animations = ["stagger", "dodge"]

var joys : Vector2
var mouse : Vector2


func _input(event):
	if event is InputEventMouseMotion:
		mouse = get_global_mouse_position()
		return

	if event is InputEventJoypadMotion:
		if Utils.get_aim_joystick_direction() != Vector2.ZERO:
			joys = Utils.get_aim_joystick_direction()
		

func _ready() -> void:
	if not OS.is_debug_build():
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

	animation_name = state_machine.get_animation_name()
	if animation_name == null:
		animation_name = "idle"


func _physics_process(_delta) -> void:

	var direction = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
		)
	set_facing(direction)
		
	set_animation()


func flip_facing() -> void:
	facing *= -1
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	
func set_facing(dir) -> void:
	if sign(dir) == 0:
		pass
	elif sign(dir) != sign(facing):
		flip_facing()


func get_facing() -> float:
	return facing


func set_animation() -> void:
	var new_state = state_machine.get_animation_name()
	if new_state != null and new_state != animation_name:
		animation_name = new_state
		$AnimatedSprite.play(animation_name)


func set_is_active(value: bool) -> void:
	is_active = value
	if not collider:
		return
	collider.disabled = not value


func get_collider() -> CollisionShape2D:
	return collider
