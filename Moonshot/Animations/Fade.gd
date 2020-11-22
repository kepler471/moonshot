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

func fade_in(rgba: String = A, should_reset: bool = false, counter: float = 0.0) -> void:
	if sceneTree != null:
		yield(sceneTree.create_timer(fade_speed), "timeout")

	if counter < 1:
		if Utils.is_nil(sprite): return
		sprite.modulate[rgba] = counter
		fade_in(rgba, should_reset, counter + fade_factor)

	else:
		if !Utils.is_nil(on_fade_in_finish):
			on_fade_in_finish.call_func()
		if should_reset:
			sprite.modulate = original_values
			on_fade_out_finish = funcref(self, "noop")

func fade_out(rgba: String = A, should_reset: bool = false, counter: float = 1.0) -> void:
	if sceneTree != null:
		yield(sceneTree.create_timer(fade_speed), "timeout")

	if counter > 0:
		if Utils.is_nil(sprite): return
		sprite.modulate[rgba] = counter
		fade_out(rgba, should_reset, counter - fade_factor)

	else:
		if !Utils.is_nil(on_fade_out_finish):
			on_fade_out_finish.call_func()
		if should_reset:
			sprite.modulate = original_values
			on_fade_out_finish = funcref(self, "noop")

func occilate(rgba: Array, timer: float = 0.5, occilations: int = 1) -> void:
	if occilations != 0:
		fade_in(rgba[occilations % rgba.size()], false)
		yield(sceneTree.create_timer(timer), "timeout")
		fade_out(rgba[occilations % rgba.size()], false)
		yield(sceneTree.create_timer(timer), "timeout")
		occilate(rgba, timer, occilations - 1)
	else:
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
