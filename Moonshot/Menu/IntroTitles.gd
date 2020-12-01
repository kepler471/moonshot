extends CanvasModulate

onready var nerdherd_logo = get_node("NERDHERDLogo")
onready var presents_text = get_node("PRESENTS")
onready var game_title = get_node("MySummerInternship")
onready var black_box = get_node("ColorRect")
onready var opacity_tween = get_node("OpacityTween")

func _ready():
	clear_titles()
	title_sequence()
	

func title_sequence():
	
	fade_in(nerdherd_logo)
	yield(opacity_tween,"tween_completed")
	fade_out(nerdherd_logo)
	yield(opacity_tween,"tween_completed")
	
	fade_in(presents_text)
	yield(opacity_tween,"tween_completed")
	fade_out(presents_text)
	yield(opacity_tween,"tween_completed")	
	
	fade_in(game_title)
	yield(opacity_tween,"tween_completed")
	fade_out(game_title,10)
	yield(opacity_tween,"tween_completed")
	
	fade_in(black_box,4)
	yield(opacity_tween,"tween_completed")
	
	get_tree().change_scene("res://Menu/Menu.tscn")
	

func fade_in(node,duration = 3.5):
	opacity_tween.interpolate_property(node, "modulate", 
		Color(1, 1, 1, 0), Color(1, 1, 1, 1), duration, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	opacity_tween.start()

func fade_out(node,duration = 6):
	opacity_tween.interpolate_property(node, "modulate", 
		Color(1, 1, 1, 1), Color(1, 1, 1, 0), duration, 
		Tween.TRANS_QUAD, Tween.EASE_IN)
	opacity_tween.start()

func clear_titles():
	nerdherd_logo.set_modulate(Color(1,1,1,0))
	presents_text.set_modulate(Color(1,1,1,0))
	game_title.set_modulate(Color(1,1,1,0))
	black_box.set_modulate(Color(1,1,1,0))
