extends Sprite

var camera_movement = 250 #would be better to get this from the node itself
onready var parallax_distance = camera_movement * get_parent().get_motion_scale().y

func _ready():
	var offset = self.position.y + parallax_distance
	print(offset)
	get_parent().set_motion_offset(Vector2(0,offset))


