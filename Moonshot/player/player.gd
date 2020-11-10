extends KinematicBody2D

onready var orig = self.position

var crosshair = load("res://player/assets/red_cross.png")
var PlayerArsenal = load("res://player/PlayerArsenal.gd")

# var scaling should be set close the the pixel height of a player.
# var scaling = 100 feels ~OK~ for 90px player.
export(int) var scaling = 64
export(int) var WALK_FORCE = 2000 * scaling
export(int) var WALK_MAX_SPEED = 6 * scaling
export(int) var STOP_FORCE = 80 * scaling
export(int) var JUMP_SPEED = 20 * scaling
export(int) var gravity = 90 * scaling

var player_arsenal = PlayerArsenal.new()
var cooldown = false
var velocity = Vector2()
var facing = 1

func flip_facing():
	facing *= -1
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h

func _ready():
	Input.set_custom_mouse_cursor(crosshair)
	

func _physics_process(delta):
	# Player input. Can vary with analog input (joysticks)
	var direction = (
		Input.get_action_strength("move_right") 
		- Input.get_action_strength("move_left")
		)
#
	if sign(direction) == 0:
		pass
	elif sign(direction) != sign(facing):
		flip_facing()
		
	var walk = WALK_FORCE * direction
	
	# Slow down the player if they're not trying to move.
	if abs(walk) < WALK_FORCE * 0.2:
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
		
	# Clamping limits a value to the given bounds.
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

	# Apply gravity.
	velocity.y += gravity * delta
	
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

	# Check for jumping. is_on_floor() must be called after movement code.
	if self.is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_SPEED

	# TODO: add directional jump from walls
	if self.is_on_wall() and Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_SPEED
		
	# Position resetting for *DEBUG*
	if Input.is_action_just_released("reset"):
		self.position = orig
		
	if Input.is_action_pressed("shoot") and !cooldown:
		var weapon = player_arsenal.get_weapon()
		var shot = weapon.shoot().instance()
		add_child(weapon.sound)

		cooldown = true
		get_node("TurnAxis").rotation = get_angle_to(get_global_mouse_position())
		
		shot.position = get_node("TurnAxis/CastPoint").get_global_position()
		shot.rotation = get_angle_to(get_global_mouse_position())
		
		get_parent().add_child(shot)

		yield(get_tree().create_timer(weapon.fire_speed), "timeout")
		cooldown = false
		
	if Input.is_action_just_pressed("zoomin"):
		pass
