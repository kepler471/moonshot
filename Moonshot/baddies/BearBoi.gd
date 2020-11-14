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

func _ready() -> void:
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	Baddie.set_sprite($AnimatedSprite)
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
	var collided_with_player = Baddie.check_player_colision(true)

	if is_on_wall() && !collided_with_player:
		Baddie.sprite.flip_h = !Baddie.sprite.flip_h
		Baddie.direction = Baddie.change_direction()

func on_hit(instance_id, damage) -> void:
	if instance_id == self.get_instance_id():
		Baddie.on_hit(damage)
