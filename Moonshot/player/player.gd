extends KinematicBody2D

onready var orig = self.position

# var scaling should be set close the the pixel height of a player.
# var scaling = 100 feels ~OK~ for 90px player.
const scaling : int = 100
const WALK_FORCE = 2000 * scaling
const WALK_MAX_SPEED = 6 * scaling
const STOP_FORCE = 80 * scaling
const JUMP_SPEED = 20 * scaling
const gravity = 90 * scaling

var velocity = Vector2()
var facing = 1

func _ready():
	set_camera_limits()


func flip_facing():
	facing *= -1
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	

func set_camera_limits():
	var map_limits = get_node("../BaseTiles").get_used_rect()
	var map_cellsize = get_node("../BaseTiles").cell_size
	print(map_limits.position)
	print(map_cellsize)
	$Camera2D.limit_left = map_limits.position.x * map_cellsize.x
	$Camera2D.limit_right = map_limits.end.x * map_cellsize.x
	$Camera2D.limit_top = map_limits.position.y * map_cellsize.y
	$Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y

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
