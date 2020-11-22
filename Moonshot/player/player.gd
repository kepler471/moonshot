extends KinematicBody2D
class_name Player

var PlayerArsenal = load("res://player/PlayerArsenal.gd")

# warning-ignore:unused_signal
signal hopped_off_entity

onready var state_machine: StateMachine = $StateMachine

onready var collider: CollisionShape2D = $CollisionShape2D setget ,get_collider


onready var ledge_wall_detector: Position2D = $LedgeWallDetector
onready var floor_detector: RayCast2D = $FloorDetector

onready var pass_through: Area2D = $PassThrough


const FLOOR_NORMAL := Vector2.UP

var is_active := true setget set_is_active
var has_teleported := false
var last_checkpoint: Area2D = null

var player_arsenal = PlayerArsenal.new()
var cooldown = false

var facing = 1
var animation_name
var playing_reverse
var invulnerable = false
var safety = false


func _input(event):
	if event.is_action_pressed("mouse_capture"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func _ready() -> void:
	
	
	
	add_child(player_arsenal)
	player_arsenal.set_weapon()

	CombatSignalController.connect("damage_player", self, "take_damage")
	CombatSignalController.connect("get_player_global_position", self, "_emit_position")
	CombatSignalController.connect("get_player_global_position_drop", self, "_emit_position_drop")


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
	CombatSignalController.emit_signal("emit_player_global_position_drop", $TurnAxis.global_position)
	set_facing(direction)
		
	set_animation()

	face_mouse()

	get_node("TurnAxis").rotation = PI + (position + get_node("TurnAxis").position).angle_to_point(get_global_mouse_position())

	if Input.is_action_pressed("shoot") and !cooldown and !safety:
		var weapon = player_arsenal.get_weapon()
		var shot = weapon.shoot().instance()

		cooldown = true

		shot.position = get_node("TurnAxis/CastPoint").get_global_position()
		shot.rotation = get_node("TurnAxis").rotation

		get_parent().add_child(shot)
		var timer_delay = weapon.fire_speed/Utils.player_stats.modifiers['firerate']
		yield(get_tree().create_timer(timer_delay), "timeout")

		cooldown = false
		
	call_deferred("damagetile_check")


func flip_facing() -> void:
	facing *= -1
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	
	
func set_facing(dir) -> void:
	if sign(dir) == 0:
		pass
	elif sign(dir) != sign(facing):
		flip_facing()


func set_animation() -> void:
	if invulnerable:
		if not $AnimatedSprite.playing:
			$AnimatedSprite.play(animation_name)
		return
	var new_state = state_machine.get_animation_name()
	if new_state != null and new_state != animation_name:
		animation_name = new_state
		$AnimatedSprite.play(animation_name)


func face_mouse() -> void:
	var mouse_side := get_global_mouse_position().x - get_global_position().x
	if is_zero_approx(mouse_side):
		return
	elif sign(mouse_side) == sign(facing) and playing_reverse:
		$AnimatedSprite.play(animation_name, false)
		playing_reverse = false
	elif sign(mouse_side) == -1 * sign(facing):
		flip_facing()
		$AnimatedSprite.play(animation_name, true)
		playing_reverse = true


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


func set_invulnerable(time : float, animation_name = "stagger") -> void:
	invulnerable = true
	safety = true
	$AnimatedSprite.play(animation_name)
	var timer = Utils.Player.get_tree().create_timer(time)
	yield(timer, "timeout")
	invulnerable = false
	safety = false
	

func damagetile_check():
	for i in self.get_slide_count():
		var collision = self.get_slide_collision(i)
		if !collision || !collision.collider:
			break
			
		if collision.collider.name == "DamageTiles":
			if is_on_floor():
				take_damage(0.1,Vector2.UP, true)
				
			elif is_on_wall():
				var wall_normal = $LedgeWallDetector.scale.x * - 1
				take_damage(0.1,Vector2(wall_normal,0) , true)


func take_damage(damage, attack_dir, damagetile: bool = false) -> void:
	if not invulnerable:
		Utils.player_stats.health -= damage
		if Utils.IS_DEBUG: print("Attack Dir : ", attack_dir)
		
		if damagetile:
			set_invulnerable(0.2) #BALANCING
			state_machine.transition_to("Move/Stagger", {"previous" : state_machine.state, "direction" : attack_dir, "damagetile" : damagetile})
		else:
			set_invulnerable(0.8) #BALANCING
			attack_dir = sign(get_global_position().x - attack_dir.x)
			state_machine.transition_to("Move/Stagger", {"previous" : state_machine.state, "direction" : attack_dir, "damagetile" : damagetile})
	
	
	if Utils.player_stats.health <= 0:
		on_death()
		
	Utils.player_stats.take_damage(1)

func add_health(health):
	var new_health = Utils.player_stats.health + health
	Utils.player_stats.health = min(Utils.player_stats.max_health, new_health)


func on_death() -> void:
	CombatSignalController.emit_signal("player_kill")
	_on_Player_health_depleted()


func _emit_position() -> void:
	CombatSignalController.emit_signal("emit_player_global_position", $TurnAxis.global_position)
	
