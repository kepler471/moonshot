extends KinematicBody2D

const GRAVITY:= 10;
const SPEED:= 30;
const FLOOR:= Vector2(0, -1);
const Animations:= {
	"GHOST": "ghost"
}

var velocity := Vector2();


enum Directions {
	LEFT = 0,
	RIGHT = 1
}

func _ready():
	pass;

func _process(delta) -> void:
	velocity.x = SPEED;
	$AnimatedSprite.play(Animations.GHOST);
	velocity.y += GRAVITY;
	pass;
