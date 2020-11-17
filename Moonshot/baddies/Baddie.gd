extends Node

const FLOOR:= Vector2(0, -1)
enum Direction {
	LEFT = -1,
	RIGHT = 1
}

export(int)var hp: float
export(int)var gravity: int
export(int)var speed: int
export(int)var direction: int = Direction.RIGHT
var animation: String
var velocity:= Vector2();
var sprite: AnimatedSprite
var body: KinematicBody2D
var inflict_damage: float = 0.2

func set_init_hp(init_hp: float) -> void:
	hp = init_hp
	
func set_move_animation(move_animation: String) -> void:
	animation = move_animation
	
func set_gravity(g: int) -> void:
	gravity = g
	
func set_speed(s: int) -> void:
	speed = s
	
func set_sprite(s: AnimatedSprite) -> void:
	sprite = s

func set_body(b: KinematicBody2D) -> void:
	body = b
	
func set_damage(d: float) -> void:
	inflict_damage = d

func move(delta) -> void:
	velocity.x = speed * direction
	sprite.play(animation)
	velocity.y += gravity

	velocity = body.move_and_slide(velocity, FLOOR)

func check_player_colision(should_damage_player = false) -> bool:
	for i in body.get_slide_count():
		var collision = body.get_slide_collision(i)
		if collision.collider != null && collision.collider.name == "Player":
			if should_damage_player:
				CombatSignalController.emit_signal("damage_player", self.inflict_damage)
			return true
	return false

func change_direction() -> int:
	return Direction.RIGHT if direction == Direction.LEFT else Direction.LEFT

func on_hit(damage: float) -> void:
	hp -= damage
	if hp <= 0:
		on_death()

func on_death() -> void:
	call_deferred("free")
