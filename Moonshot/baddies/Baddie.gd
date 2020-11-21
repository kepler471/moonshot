extends Node
class_name Baddie

enum Direction {
	LEFT = -1,
	RIGHT = 1
}

var dead = false
var inital_hp: float
var hp: float
var gravity: int
var speed: int = 230
var direction: int = Direction.RIGHT
var animation: String
var velocity:= Vector2();
var sprite: AnimatedSprite
var floor_vector = Vector2(0, -1)
var body: KinematicBody2D
var damage_to_player: float = 0.2
var should_damge_on_collision = false
var flipped_horizontal: bool = false
var flipped_vertical: bool = false
var current_state = {}

func get_default_stats() -> Dictionary:
#    make sure this stays as flat as possible
	return {
		"inital_hp": 1.0,
		"gravity": 10,
		"speed": 230,
		"direction": Direction.RIGHT,
		"sprite": null,
		"velocity": Vector2(),
		"floor_vector": Vector2(0, -1),
		"body": null,
		"animation": "rush",
		"damage_to_player": 0.02,
		"should_damge_on_collision": false
	}

func get_current_state() -> Dictionary:
	return {
		"inital_hp":inital_hp,
		"gravity": gravity,
		"speed": speed,
		"direction": direction,
		"sprite": sprite,
		"velocity":velocity,
		"floor_vector": floor_vector,
		"body": body,
		"animation": animation,
		"damage_to_player": damage_to_player,
		"should_damge_on_collision": should_damge_on_collision
	}

func patch(patch = {}) -> void:
	var new_properties = Utils.merge_dictionary(get_current_state(), patch)
	for key in new_properties:
		set(key, new_properties[key])
	

func set_properties(properties: Dictionary = {}) -> void:
	var new_properties = Utils.merge_dictionary(get_default_stats(), properties)
	for key in new_properties:
		set(key, new_properties[key])
		
	hp = new_properties.inital_hp

func get(key: String, fallback = null):
	return self[key] || fallback

func set(key: String, value) -> void:
	self[key] = value

func get_in(keys: Array) -> void:
	Utils.get_in_dictionary(self, keys)

# for deep updates on something like `velocity.x`
func set_in(keys: Array, value) -> void:
	Utils.set_in_dictionary(keys, value, self)
	
func set_damage(d: float) -> void:
	damage_to_player = d

func move(delta) -> void:
	velocity.x = speed * direction
	sprite.play(animation)
	velocity.y += gravity

	velocity = body.move_and_slide(velocity, floor_vector)

func check_player_colision() -> bool:
	for i in body.get_slide_count():
		var collision = body.get_slide_collision(i)
		if !collision || !collision.collider:
			break
		if collision.collider.name == "Player":
			if should_damge_on_collision:
				if Utils.IS_DEBUG: print("hit by melee with x := ", body.position)
				CombatSignalController.emit_signal("damage_player", self.damage_to_player, body.position)
			return true
	return false

func change_direction() -> int:
	return Direction.RIGHT if direction == Direction.LEFT else Direction.LEFT

func flip_sprite_horizontal() -> void:
	sprite.flip_h = !sprite.flip_h

func flip_sprite_vertical() -> void:
	sprite.flip_v = !sprite.flip_v

func on_hit(damage: float) -> void:
	hp -= damage
	if hp <= 0:
		on_death()

func has_died() -> bool:
	return dead == true

func on_death() -> void:
	dead = true
