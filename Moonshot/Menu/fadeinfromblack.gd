extends Node2D

onready var opacity_tween = get_node("opacityTween")

func _ready():
	fade_out(self)

func fade_out(node):
	opacity_tween.interpolate_property(node, "modulate", 
		Color(1, 1, 1, 1), Color(1, 1, 1, 0), 3, 
		Tween.TRANS_QUAD, Tween.EASE_IN)
	opacity_tween.start()
