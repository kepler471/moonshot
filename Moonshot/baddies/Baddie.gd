extends KinematicBody2D

const GRAVITY:= 10
const SPEED:= 75
const FLOOR:= Vector2(0, -1)
const Animations:= {
	"GHOST": "ghost"
}

enum Directions {
	LEFT = -1,
	RIGHT = 1
}

export(int) var hp_max = 100
var hp

var direction: int = Directions.RIGHT
var velocity:= Vector2();

func _ready():
	hp = hp_max

func _process(delta) -> void:
	velocity.x = SPEED * direction
	$AnimatedSprite.play(Animations.GHOST)
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)

	if is_on_wall():
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
		direction = change_direction(direction)

	pass;

func change_direction(direction: int) -> int:
	if direction == Directions.LEFT:
		return Directions.RIGHT
	return Directions.LEFT

func on_hit(damage):
	hp -= damage
	if hp <= 0:
		on_death()

func on_death():
	get_node("CollisionShape2D").set_deferred("disabled", true)
	call_deferred("free")
