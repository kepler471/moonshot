extends Node
class_name Fade

var sprite: AnimatedSprite setget set_sprite
var sceneTree: SceneTree setget set_tree
var fade_factor: float = 0.1 setget set_fade_factor
var fade_speed: float setget set_fade_speed
var on_end: FuncRef setget set_on_end
var on_fade_in_finish: FuncRef = funcref(self, "noop") setget set_on_fade_in_finish
var on_fade_out_finish: FuncRef = funcref(self, "noop") setget set_on_fade_out_finish

var has_faded: bool = false
var is_fading: bool = false

var has_faded_in: bool = false
var is_fading_in: bool = false

func fade_in(counter: float = 0.0) -> void:
	if counter != 1 && !has_faded_in:
		is_fading_in = true

		if sceneTree != null:
			yield(sceneTree.create_timer(fade_speed), "timeout")

		sprite.modulate.a = counter
		fade_in(counter + fade_factor)

	else:
		has_faded_in = true
		on_fade_in_finish.call_func()

func fade_out(counter: float = 1.0) -> void:
	if counter > 0 && !has_faded:
		is_fading = true

		if sceneTree != null:
			yield(sceneTree.create_timer(fade_speed), "timeout")

		sprite.modulate.a = counter
		fade_out(counter - fade_factor)

	else:
		has_faded = true
		print(on_fade_out_finish)
		on_fade_out_finish.call_func()

func set_tree(t: SceneTree) -> void:
	sceneTree = t

func set_sprite(s: AnimatedSprite) -> void:
	sprite = s

func set_fade_factor(d: float) -> void:
	fade_factor = d

func set_fade_speed(s: float) -> void:
	fade_speed = s

func set_on_end(fn: FuncRef) -> void:
	on_end = fn

func set_on_fade_in_finish(fn :FuncRef) -> void:
	on_fade_in_finish = fn

func set_on_fade_out_finish(fn :FuncRef) -> void:
	on_fade_out_finish = fn

func noop() -> void:
	return
