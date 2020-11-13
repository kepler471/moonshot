extends KinematicBody2D

var Baddie = load("res://baddies/Baddie.gd").new()
const GRAVITY:= 8
const SPEED:= 230
const HP_MAX = 100
const FLOOR:= Vector2(0, -1)
const Animations:= {
	"WALK": "walk"
}

func _ready() -> void:
	Baddie.set_sprite($AnimatedSprite)
	Baddie.set_collision_node($CollisionPolygon2D)
	Baddie.set_body(self)
	Baddie.set_gravity(GRAVITY)
	Baddie.set_speed(SPEED)
	Baddie.set_init_hp(HP_MAX)
	Baddie.set_move_animation(Animations.WALK)

func _process(delta) -> void:
	call_deferred("free") if Baddie == null else Baddie.move(delta)
	
func on_hit(damage) -> void:
	Baddie.on_hit(damage)
