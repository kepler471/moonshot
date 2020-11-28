extends Sprite

var state_dictionary: Dictionary = {
  "red": load("res://assets/environment/LiftButtonRed.png"),
  "green": load("res://assets/environment/LiftButtonGreen.png"),
  "on": load("res://assets/environment/LiftButtonON.png")
}

func _ready():
	set_texture(state_dictionary["red"])

func change_texture(state):
	set_texture(state_dictionary[state])
