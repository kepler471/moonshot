extends KinematicBody2D

class_name Player 



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
var player_arsenal

var cooldown = false

var facing = 1
var animation_name
var playing_reverse
var invulnerable = false
var safety = false
var dead = false
var priority_animations = ["stagger", "dodge"]


func _input(event):
	if event.is_action_pressed("mouse_capture"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func _ready() -> void:
	CombatSignalController.connect("damage_player", self, "take_damage")
	CombatSignalController.connect("get_player_global_position", self, "_emit_position")
	CombatSignalController.connect("get_player_global_position_drop", self, "_emit_position_drop")
	
	Utils.player_arsenal.reset_arsenal()
	Utils.player_arsenal.set_weapon('laser_blaster')

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
		var weapon = Utils.player_arsenal.get_weapon()
		if weapon.ammo == 0:
			Utils.player_arsenal.set_weapon('laser_blaster')
			weapon = Utils.player_arsenal.get_weapon()
		var shots = weapon.shoot()

		cooldown = true
		
		for i in range(len(shots)):
			var shot = shots[i]
			var shot_rotation_modifier = weapon.shot_rotation_modifiers[i]
			shot.position = get_node("TurnAxis/CastPoint").get_global_position()
			shot.rotation = get_node("TurnAxis").rotation 
			var random_spread
			if "shot_spread" in weapon:
				random_spread = rand_range(-weapon.shot_spread, weapon.shot_spread)
			else:
				random_spread = 0
			shot.rotation += ((shot_rotation_modifier + random_spread)*2*PI) / 360 
			get_parent().add_child(shot)
		

		var timer_delay = weapon.fire_speed/Utils.player_stats.modifiers['firerate']
		yield(get_tree().create_timer(timer_delay), "timeout")

		cooldown = false
		
	if damagetile_check() and not dead:
		damagetile_impulse()
	
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
	if invulnerable and animation_name in priority_animations:
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


func set_invulnerable(time : float, _anim_name) -> void:
	invulnerable = true
	$Shield.set_visible(true)
	if _anim_name != "stagger":
		safety = true
	if _anim_name in priority_animations:
		$AnimatedSprite.play(_anim_name)
	var timer = Utils.Player.get_tree().create_timer(time)
	yield(timer, "timeout")
	invulnerable = false
	$Shield.set_visible(false)
	safety = false


func damagetile_check():
	for i in self.get_slide_count():
		var collision = self.get_slide_collision(i)
		if !collision || !collision.collider:
			break
			
		if collision.collider.name == "DamagePools" or collision.collider.name == "DamageWalls":
			return true
		else:
			return false

func damagetile_impulse():
	$SFX.play("sizzle")
	if is_on_floor():
		take_damage(0.1,Vector2.UP, true)
		
	elif is_on_wall():
		var wall_normal = $LedgeWallDetector.scale.x * - 1
		take_damage(0.1,Vector2(wall_normal,0) , true)


func take_damage(damage, attack_dir, is_damage_tile: bool = false) -> void:

	if not invulnerable and not dead:
		$SFX.play("pain")
		Utils.player_stats.take_damage(damage)

		if Utils.IS_DEBUG: print("Attack Dir : ", attack_dir)
		if Utils.player_stats.health <= 0:
			on_death()
			safety = true
			return
		if is_damage_tile:
			set_invulnerable(0.5, "stagger") #BALANCING
			stagger_player(attack_dir,is_damage_tile)
		else:
			set_invulnerable(0.8, "stagger") #BALANCING
			attack_dir = sign(get_global_position().x - attack_dir.x)
			stagger_player(attack_dir,is_damage_tile)



func add_health(health) -> void:
	$SFX.play("health")
	var new_health = Utils.player_stats.health + health
	Utils.player_stats.health = min(Utils.player_stats.max_health, new_health)


func on_death() -> void:
	dead = true
	$SFX.play("death")
	CombatSignalController.emit_signal("player_kill")
	_on_Player_health_depleted()
	CombatSignalController.disconnect("damage_player", self, "take_damage")
	


func _on_Player_health_depleted() -> void:
	state_machine.transition_to("Die", {last_checkpoint = last_checkpoint})


func _emit_position() -> void:
	CombatSignalController.emit_signal("emit_player_global_position", $TurnAxis.global_position)


func stagger_player(attack_dir, is_damage_tile) -> void:
	state_machine.transition_to("Move/Stagger", {"previous" : state_machine.state, "direction" : attack_dir, "is_damage_tile" : is_damage_tile})
