extends Node

const FLOOR:= Vector2(0, -1)
enum Direction {
	LEFT = -1,
	RIGHT = 1
}

export(int)var hp: int
export(int)var gravity: int
export(int)var speed: int
export(int)var direction: int = Direction.RIGHT
var animation: String
var velocity:= Vector2();
var sprite: AnimatedSprite
var body: KinematicBody2D
var collision_node: CollisionPolygon2D
var inflict_damage: int = 20

func set_init_hp(init_hp: int) -> void:
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

func set_collision_node(n: CollisionPolygon2D) -> void:
	collision_node = n
	
func set_damage(d: int) -> void:
	inflict_damage = d

func move(delta) -> void:
	velocity.x = speed * direction
	sprite.play(animation)
	velocity.y += gravity

	velocity = body.move_and_slide(velocity, FLOOR)


func change_direction() -> int:
	return Direction.RIGHT if direction == Direction.LEFT else Direction.LEFT

func on_hit(damage) -> void:
	hp -= damage
	if hp <= 0:
		on_death()

func on_death() -> void:
	collision_node.set_deferred("disabled", true)
	call_deferred("free")
