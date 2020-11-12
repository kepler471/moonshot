extends Node

class LaserBlaster:
	var sound = AudioStreamPlayer2D.new()
	var bullet = load("res://player/bullet.tscn")
	var sfx = load("res://player/assets/sounds/laser_pew.ogg") 
	var fire_speed = 0.25
	
	func _init():
		sfx.set_loop(false)
		sound.stream = sfx

	func shoot():
		sound.play()
		return bullet

const weapon_type = {
	LASER_BLASER = "laser_blaster"
}

var current_weapon_type = weapon_type.LASER_BLASER
var arsenal: Dictionary = {
	"laser_blaster": LaserBlaster.new()
}

func get_weapon():
	if !arsenal.has(current_weapon_type):
		return null
	return arsenal.get(current_weapon_type)

func set_weapon(new_weapon) -> void:
	current_weapon_type = new_weapon
