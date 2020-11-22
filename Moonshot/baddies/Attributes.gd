extends Node
class_name Attributes

onready var fade: Fade

var firerate_boost_drop = load("res://items_objects/FireRatePickup.tscn")
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
var shot_speed = 500
var shot_damage = 0.5
var item_drop = null
var on_death: FuncRef

func _init():
	fade = load("res://Animations/Fade.gd").new()
	
func _ready():
	get_parent().add_child(fade)
	fade.set_tree(get_tree())

func get_current_state() -> Dictionary:
	return {
		"inital_hp": inital_hp,
		"gravity": gravity,
		"speed": speed,
		"direction": direction,
		"sprite": sprite,
		"velocity": velocity,
		"floor_vector": floor_vector,
		"body": body,
		"animation": animation,
		"damage_to_player": damage_to_player,
		"should_damge_on_collision": should_damge_on_collision,
		"shot_speed": shot_speed,
		"shot_damage": shot_damage,
		"item_drop": item_drop,
		"on_death": on_death
	}

func _get_default_baddie_attributes():
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
		"should_damge_on_collision": false,
		"shot_speed": 500,
		"shot_damage": 0.4,
		"item_drop": null
	}

func patch(patch = {}):
	var new_properties = Utils.merge_dictionary(get_current_state(), patch)
	for key in new_properties:
		set(key, new_properties[key])

	
func set_properties(attributes: Dictionary = {}):
	var new_properties = Utils.merge_dictionary(_get_default_baddie_attributes(), attributes)
	for key in new_properties:
		set(key, new_properties[key])
		
	hp = new_properties.inital_hp
	fade.set_on_fade_out_finish(funcref(body, "on_end"))
	fade.set_fade_speed(0.05)
	fade.set_fade_factor(0.3)
	body.add_child(self)


func get(key: String, fallback = null):
	return self[key] if self[key] != null else fallback

func set(key: String, value):
	self[key] = value

func set_sprite(s: AnimatedSprite) -> void:
	sprite = s
	fade.set_sprite(sprite)

func flip_sprite_horizontal() -> void:
	sprite.flip_h = !sprite.flip_h

func flip_sprite_vertical() -> void:
	sprite.flip_v = !sprite.flip_v

func _move(delta) -> void:
	velocity.x = speed * direction
	sprite.play(animation)
	velocity.y += gravity

	velocity = body.move_and_slide(velocity, floor_vector)

func _check_player_colision() -> bool:
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

func _change_direction() -> int:
	return Direction.RIGHT if direction == Direction.LEFT else Direction.LEFT

func _on_hit(damage: float, global_position: Vector2) -> void:
	hp -= damage
	if hp <= 0:
		_is_dying(global_position)

func _is_dying(global_position) -> bool:
	var new_firerate_boost = firerate_boost_drop.instance()

	var room_scene = Utils.Player.get_parent()
	room_scene.call_deferred('add_child', new_firerate_boost)
	new_firerate_boost.global_position = global_position
	dead = true
	sprite.stop()
	fade.fade_out()
	return true


func _has_died() -> bool:
	return dead == true

func _noop() -> void:
	return
