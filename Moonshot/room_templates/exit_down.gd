extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Exit_DOWN_body_entered(body):
	if body.is_in_group("Player") and not LevelController.changing_room:
		LevelController.changing_room = true
		print("Exit DOWN")
		LevelController.change_room(Vector2.DOWN, 'UP')
