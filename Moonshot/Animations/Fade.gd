extends Node
class_name Fade

const R: String = "r"
const G: String = "g"
const B: String = "b"
const A: String = "a"

var sprite: AnimatedSprite setget set_sprite
var sceneTree: SceneTree setget set_tree
var fade_factor: float = 0.1 setget set_fade_factor
var fade_speed: float setget set_fade_speed
var on_fade_in_finish: FuncRef = funcref(self, "noop") setget set_on_fade_in_finish
var on_fade_out_finish: FuncRef = funcref(self, "noop") setget set_on_fade_out_finish
var original_values: Color
var is_animating: bool = false
var is_oscillating: bool = false

func fade_in(rgba: String = A, should_reset: bool = false, counter: float = 0.0) -> void:
	if is_animating == true:
		return

	if !is_inside_tree() || !is_instance_valid(self):
		queue_free()
		return

	if counter < 1 && sceneTree != null:
		is_animating = true
		if Utils.is_nil(sprite): return
		yield(create_timer(), "timeout")
		sprite.modulate[rgba] = counter
		is_animating = false
		fade_in(rgba, should_reset, counter + fade_factor)

	else:
		if !Utils.is_nil(on_fade_in_finish):
			on_fade_in_finish.call_func()
		if should_reset:
			sprite.modulate = original_values
			on_fade_out_finish = funcref(self, "noop")
		is_animating = false

func fade_out(rgba: String = A, should_reset: bool = false, counter: float = 1.0) -> void:
	if is_animating == true:
		return

	if !is_inside_tree() || !is_instance_valid(self):
		queue_free()
		return

	if counter > 0 &&  sceneTree != null:
		is_animating = true
		if Utils.is_nil(sprite): return
		yield(create_timer(), "timeout")
		sprite.modulate[rgba] = counter
		is_animating = false
		fade_out(rgba, should_reset, counter - fade_factor)

	else:
		if !Utils.is_nil(on_fade_out_finish):
			on_fade_out_finish.call_func()
		if should_reset:
			sprite.modulate = original_values
			on_fade_out_finish = funcref(self, "noop")
		is_animating = false

func oscillate(rgba: Array, timer: float = 0.3, oscillations: int = 1) -> void:
	if is_oscillating == true || is_animating == true:
		return

	if !is_inside_tree() || !is_instance_valid(self):
		queue_free()
		return

	if oscillations != 0:
		fade_in(rgba[oscillations % rgba.size()], false)
		is_oscillating = true
		yield(create_timer(timer), "timeout")
		is_oscillating = false
		oscillate(rgba, timer, oscillations - 1)
	else:
		is_oscillating = false
		is_animating = false
		sprite.modulate = original_values

func set_tree(t: SceneTree) -> void:
	sceneTree = t

func set_sprite(s: AnimatedSprite) -> void:
	sprite = s
	original_values = Color(sprite.modulate)

func set_fade_factor(d: float) -> void:
	fade_factor = d

func set_fade_speed(s: float) -> void:
	fade_speed = s

func set_on_fade_in_finish(fn: FuncRef) -> void:
	on_fade_in_finish = fn

func set_on_fade_out_finish(fn: FuncRef) -> void:
	on_fade_out_finish = fn

func noop() -> void:
	return

func create_timer(timer_speed = fade_speed):
	return sceneTree.create_timer(timer_speed)

func remove():
	call_deferred("free")
