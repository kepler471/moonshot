extends KinematicBody2D

signal damage_player

var Baddie = load("res://baddies/Baddie.gd").new()
const GRAVITY:= 8
const SPEED:= 230
const HP_MAX = 100
const FLOOR:= Vector2(0, -1)
const Animations:= {
	"RUSH": "rush"
}
onready var colider = $CollisionPolygon2D

func _ready() -> void:
	Baddie.set_sprite($AnimatedSprite)
	Baddie.set_collision_node($CollisionPolygon2D)
	Baddie.set_body(self)
	Baddie.set_gravity(GRAVITY)
	Baddie.set_speed(SPEED)
	Baddie.set_init_hp(HP_MAX)
	Baddie.set_move_animation(Animations.RUSH)
	Baddie.set_damage(10)

func _process(delta) -> void:
	check_player_colision()
	call_deferred("free") if Baddie == null else Baddie.move(delta)
	
func on_hit(damage) -> void:
	Baddie.on_hit(damage)

func check_player_colision() -> void:
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Player":
			emit_signal("damage_player", Baddie.inflict_damage)
