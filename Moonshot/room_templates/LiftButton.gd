extends Sprite

var red = load("res://assets/environment/LiftButtonRed.png")
var green = load("res://assets/environment/LiftButtonGreen.png")
var on = load("res://assets/environment/LiftButtonON.png")

func _ready():
	set_texture(red)

func change_texture(state):
	match state:
		"red":
			set_texture(red)
		"green":
			set_texture(green)
		"on":
			set_texture(on)
