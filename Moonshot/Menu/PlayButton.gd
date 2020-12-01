extends Area2D

var inside_play = false
var start = Vector2(0,-130)
var end = Vector2(0,-180)

onready var tween = get_node("PlayTween")
onready var sprite = get_node("sprite")

func _process(_delta):
	if inside_play == false:
		sprite.set_modulate(Color(1,1,1,0))

func move(dir):
	match dir:
		"up":
			tween.interpolate_property(sprite, "position", 
				start, end, 1, 
				Tween.TRANS_EXPO, Tween.EASE_OUT)
			tween.start()
		"down":
			tween.interpolate_property(sprite, "position",
				end, start, 1, 
				Tween.TRANS_EXPO, Tween.EASE_OUT)
			tween.start()

func fade(dir):
	match dir:
		"in":
			tween.interpolate_property(sprite, "modulate", 
				Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, 
				Tween.TRANS_EXPO, Tween.EASE_OUT)
			tween.start()
		"out":
			tween.interpolate_property(sprite, "modulate", 
				Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, 
				Tween.TRANS_EXPO, Tween.EASE_OUT)
			tween.start()
			
			
func _on_PlayButton_body_entered(body):
	inside_play = true
	move("up")
	fade("in")

func _on_PlayButton_body_exited(body):
	move("down")
	fade("out")
	yield(tween,"tween_completed")
	inside_play = false
