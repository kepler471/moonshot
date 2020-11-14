extends KinematicBody2D
class_name Player

var crosshair = load("res://player/assets/red_cross.png")
var PlayerArsenal = load("res://player/PlayerArsenal.gd")

# warning-ignore:unused_signal
signal hopped_off_entity

onready var state_machine: StateMachine = $StateMachine

#onready var skin: Position2D = $Skin
onready var collider: CollisionShape2D = $CollisionShape2D setget ,get_collider

onready var stats: Stats = $Stats
#onready var hitbox: Area2D = $HitBox

#onready var camera_rig: Position2D = $CameraRig
#onready var shaking_camera: Camera2D = $CameraRig/ShakingCamera

onready var ledge_wall_detector: Position2D = $LedgeWallDetector
onready var floor_detector: RayCast2D = $FloorDetector

onready var pass_through: Area2D = $PassThrough


const FLOOR_NORMAL := Vector2.UP
const MAX_HEALTH := 100

var is_active := true setget set_is_active
var has_teleported := false
var last_checkpoint: Area2D = null

var player_arsenal = PlayerArsenal.new()
var cooldown = false
var velocity = Vector2()
var facing = 1

func flip_facing():
	facing *= -1
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h

func _ready() -> void:
	add_child(player_arsenal)

	CombatSignalController.connect("damage_player", self, "take_damage")
	CombatSignalController.connect("player_kill", self, "on_death")

	var crosshair_centre = Vector2(16,16)
	Input.set_custom_mouse_cursor(crosshair, 0, crosshair_centre)

	stats.connect("health_depleted", self, "_on_Player_health_depleted")

func _physics_process(_delta) -> void:
	var direction = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
		)

	if sign(direction) == 0:
		pass
	elif sign(direction) != sign(facing):
		flip_facing()

	# begin Shooting
	get_node("TurnAxis").rotation = PI + (position + get_node("TurnAxis").position).angle_to_point(get_global_mouse_position())

	if Input.is_action_pressed("shoot") and !cooldown:
		var weapon = player_arsenal.get_weapon()
		var shot = weapon.shoot().instance()

		cooldown = true

		shot.position = get_node("TurnAxis/CastPoint").get_global_position()
		shot.rotation = get_node("TurnAxis").rotation

		get_parent().add_child(shot)

		yield(get_tree().create_timer(weapon.fire_speed), "timeout")

		cooldown = false

func set_is_active(value: bool) -> void:
	is_active = value
	if not collider:
		return
	collider.disabled = not value
	ledge_wall_detector.is_active = value


func get_collider() -> CollisionShape2D:
	return collider

func _on_Player_health_depleted() -> void:
	state_machine.transition_to("Die", {last_checkpoint = last_checkpoint})

func take_damage(damage) -> void:
	stats.health -= damage
	if stats.health <= 0:
		on_death()

func on_death() -> void:
	CombatSignalController.emit_signal("player_kill")
	call_deferred("free")
