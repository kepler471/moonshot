extends KinematicBody2D

var Baddie = load("res://baddies/Baddie.gd").new()
const GRAVITY := 8
const SPEED := 230
const HP_MAX := 1.0
const FLOOR := Vector2(0, -1)
const DAMAGE_TO_PLAYER := 0.02
const Animations := {
	"RUSH": "rush"
}
onready var colider = $CollisionPolygon2D

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", Baddie, "on_hit")
	Baddie.set_sprite($AnimatedSprite)
	Baddie.set_collision_node($CollisionPolygon2D)
	Baddie.set_body(self)
	Baddie.set_gravity(GRAVITY)
	Baddie.set_speed(SPEED)
	Baddie.set_init_hp(HP_MAX)
	Baddie.set_move_animation(Animations.RUSH)
	Baddie.set_damage(DAMAGE_TO_PLAYER)

func _process(delta) -> void:
	if Baddie == null:
		call_deferred("free")
		return
		
	Baddie.move(delta)
	var collided_with_player = check_player_colision()

	if is_on_wall() && !collided_with_player:
		Baddie.sprite.flip_h = !Baddie.sprite.flip_h
		Baddie.direction = Baddie.change_direction()

func check_player_colision() -> bool:
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Player":
			CombatSignalController.emit_signal("damage_player", Baddie.inflict_damage)
			return true
	return false
