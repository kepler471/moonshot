extends Node

class LaserBlaster:
	var sound = AudioStreamPlayer2D.new()
	var bullet = load("res://Combat/bullet.tscn")
	var sfx = load("res://player/assets/sounds/laser_pew.ogg") 
	var fire_speed = 0.25
	var f_mag = 800
	var damage = 0.4
	var no_shots = 1
	var shot_rotation_modifiers = [0]
	
	func _init():
		sfx.set_loop(false)
		sound.stream = sfx


	func shoot():
		sound.play()
		var shots = []
		var shot
		for i in range(no_shots):
			shot = bullet.instance()
			shot.f_mag = f_mag
			shot.damage = damage
			shots.append(shot) 
		return shots

		
		
class MachineGunBlaster:
	var sound = AudioStreamPlayer2D.new()
	var bullet = load("res://Combat/bullet.tscn")
	var sfx = load("res://player/assets/sounds/laser_pew.ogg") 
	var fire_speed = 0.05
	var f_mag = 800
	var damage = 0.09
	var no_shots = 1
	var shot_scale = Vector2(1, 0.25)
	var shot_rotation_modifiers = [0]
	
	func _init():
		sfx.set_loop(false)
		sound.stream = sfx


	func shoot():
		sound.play()
		var shots = []
		var shot
		for i in range(no_shots):
			shot = bullet.instance()
			shot.f_mag = f_mag
			shot.damage = damage
			shot.scale = shot_scale
			var shot_children = shot.get_children()
			for shot_child in shot_children:
				shot_child.scale = shot_scale
				shot_child.scale = shot_scale
			shots.append(shot) 
		return shots

class ShotgunBlaster:
	var sound = AudioStreamPlayer2D.new()
	var bullet = load("res://Combat/bullet.tscn")
	var sfx = load("res://player/assets/sounds/laser_pew.ogg") 
	var fire_speed = 0.9
	var f_mag = 800
	var damage = 0.2
	var no_shots = 5
	var shot_rotation_modifiers = [-10, -5, 0, 5, 10]
	
	func _init():
		sfx.set_loop(false)
		sound.stream = sfx


	func shoot():
		sound.play()
		var shots = []
		var shot
		for i in range(no_shots):
			shot = bullet.instance()
			shot.f_mag = f_mag
			shot.damage = damage
			shots.append(shot) 
		return shots
		
class TwinShotBlaster:
	var sound = AudioStreamPlayer2D.new()
	var bullet = load("res://Combat/bullet.tscn")
	var sfx = load("res://player/assets/sounds/laser_pew.ogg") 
	var fire_speed 
	var f_mag
	var damage 
	var no_shots = 2
	var shot_rotation_modifiers = [-10, 10]
	
	func _init():
		sfx.set_loop(false)
		sound.stream = sfx
		# set the attributes to be the same as the LaserBlaster
		var laser_blaster = LaserBlaster.new()
		fire_speed = laser_blaster.fire_speed
		f_mag = laser_blaster.f_mag
		damage = laser_blaster.damage

	func shoot():
		sound.play()
		var shots = []
		var shot
		for i in range(no_shots):
			shot = bullet.instance()
			shot.f_mag = f_mag
			shot.damage = damage
			shots.append(shot) 
		return shots
		
class BigBlaster:
	var sound = AudioStreamPlayer2D.new()
	var bullet = load("res://Combat/bullet.tscn")
	var sfx = load("res://player/assets/sounds/laser_pew.ogg") 
	var fire_speed = 0.75
	var f_mag = 600
	var damage = 0.5
	var no_shots = 1
	var shot_scale = Vector2(4, 4)
	var shot_rotation_modifiers = [0]
	
	func _init():
		sfx.set_loop(false)
		sound.stream = sfx


	func shoot():
		sound.play()
		var shots = []
		var shot
		for i in range(no_shots):
			shot = bullet.instance()
			shot.f_mag = f_mag
			shot.damage = damage
			var shot_children = shot.get_children()
			for shot_child in shot_children:
				shot_child.scale = shot_scale
				shot_child.scale = shot_scale
			shots.append(shot) 
		return shots
		
class BrokenBlaster:
	var sound = AudioStreamPlayer2D.new()
	var bullet = load("res://Combat/bullet.tscn")
	var sfx = load("res://player/assets/sounds/laser_pew.ogg") 
	var fire_speed 
	var f_mag 
	var damage 
	var no_shots = 1
	var shot_scale = Vector2(1, 1)
	var shot_rotation_modifiers = [0]
	# Shot random spread in angles
	var shot_spread = 10
	
	func _init():
		sfx.set_loop(false)
		sound.stream = sfx
		var laser_blaster = LaserBlaster.new()
		fire_speed = laser_blaster.fire_speed
		f_mag = laser_blaster.f_mag
		damage = laser_blaster.damage


	func shoot():
		#sound.play()
		var shots = []
		var shot
		for i in range(no_shots):
			shot = bullet.instance()
			shot.f_mag = f_mag
			shot.damage = damage
			var shot_children = shot.get_children()
			for shot_child in shot_children:
				shot_child.scale = shot_scale
				shot_child.scale = shot_scale
			shots.append(shot) 
		return shots
		
const weapon_type = {
	LASER_BLASER = "laser_blaster",
	MACHINE_GUN = "machine_gun",
	SHOTGUN = 'shotgun',
	TWIN_SHOT = 'twin_shot',
	BIG = 'big',
	BROKEN = 'broken'
}

var current_weapon_type = weapon_type.LASER_BLASER
var arsenal: Dictionary = {
	"laser_blaster": LaserBlaster.new(),
	"machine_gun": MachineGunBlaster.new(),
	"shotgun": ShotgunBlaster.new(),
	"twin_shot": TwinShotBlaster.new(),
	"big": BigBlaster.new(),
	"broken": BrokenBlaster.new()
}

func get_weapon():
	if !arsenal.has(current_weapon_type):
		return null
	return arsenal.get(current_weapon_type)

func set_weapon(new_weapon: String = "broken") -> void:
	current_weapon_type = new_weapon
	get_parent().add_child(get_weapon().sound)

