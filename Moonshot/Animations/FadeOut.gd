extends Node
class_name FadeOut

var sprite: AnimatedSprite setget set_sprite
var sceneTree: SceneTree setget set_tree
var fade_decrementer: float setget set_fade_decrementer
var fade_speed: float setget set_fade_speed
var on_end: FuncRef setget set_on_end

var has_faded: bool = false
var is_fading: bool = false

func fade(counter = 1) -> void:
	if !is_fading:
		sprite.stop()

	if counter > 0 && !has_faded:
		is_fading = true

		if sceneTree != null:
			yield(sceneTree.create_timer(fade_speed), "timeout")

		sprite.modulate.a = counter
		fade(counter - 0.1)

	else:
		has_faded = true
		if on_end != null:
			on_end.call_func()

func set_tree(t: SceneTree) -> void:
	sceneTree = t

func set_sprite(s: AnimatedSprite) -> void:
	sprite = s

func set_fade_decrementer(d: float) -> void:
	fade_decrementer = d

func set_fade_speed(s: float) -> void:
	fade_speed = s

func set_on_end(fn: FuncRef) -> void:
	on_end = fn
