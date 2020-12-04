extends Node

signal update_hud
	
class LaserBlaster:
	var name = 'laser_blaster'
	var bullet = load("res://Combat/bullet.tscn")
	var fire_speed = 0.25
	var f_mag = 1200
	var damage = 0.4
	var no_shots = 1
	var shot_rotation_modifiers = [0]
	# set to positive, doesn't go down
	var ammo = 999
	

	func shoot():
		var shots = []
		var shot
		for _i in range(no_shots):
			shot = bullet.instance()
			shot.f_mag = f_mag
			shot.damage = damage
			shots.append(shot) 
		Utils.player_arsenal.update_hud()
		return shots
			
	func pickup_ammo():
		pass
	


		
		
class MachineGunBlaster:
	var name = "machine_gun"
	var bullet = load("res://Combat/bullet.tscn")
	var fire_speed = 0.05
	var f_mag = 800
	var damage = 0.15
	var no_shots = 1
	var shot_scale = Vector2(1, 0.25)
	var shot_rotation_modifiers = [0]
	var ammo_time = 20
	var ammo 
	
	func _init():
		ammo = ammo_time/fire_speed


	func shoot():
		var shots = []
		var shot
		for _i in range(no_shots):
			shot = bullet.instance()
			shot.f_mag = f_mag
			shot.damage = damage
			shot.scale = shot_scale
			var shot_children = shot.get_children()
			for shot_child in shot_children:
				shot_child.scale = shot_scale
				shot_child.scale = shot_scale
			shots.append(shot) 
		ammo -= 1
		Utils.player_arsenal.update_hud()
		return shots
		
	func update_hud():
		emit_signal('update_hud')
		
		
	func pickup_ammo():
		ammo += ammo_time/fire_speed
		
class ShotgunBlaster:
	var name = "shotgun"
	var bullet = load("res://Combat/bullet.tscn")
	var fire_speed = 0.5
	var f_mag = 800
	var damage = 0.2
	var no_shots = 5
	var shot_rotation_modifiers = [-10, -5, 0, 5, 10]
	var ammo_time = 20
	var ammo 
	
	
	func _init():
		ammo = ammo_time/fire_speed


	func shoot():
		var shots = []
		var shot
		for _i in range(no_shots):
			shot = bullet.instance()
			shot.f_mag = f_mag
			shot.damage = damage
			shots.append(shot) 
		ammo -= 1
		Utils.player_arsenal.update_hud()
		return shots
		
	func update_hud():
		emit_signal('update_hud')
			
	func pickup_ammo():
		ammo += ammo_time/fire_speed
		
class TwinShotBlaster:
	var name = 'twin_shot'
	var bullet = load("res://Combat/bullet.tscn")
	var fire_speed 
	var f_mag
	var damage 
	var no_shots = 2
	var shot_rotation_modifiers = [-10, 10]
	var ammo_time = 20
	var ammo 
	
	
	func _init():
		# set the attributes to be the same as the LaserBlaster
		var laser_blaster = LaserBlaster.new()
		fire_speed = laser_blaster.fire_speed
		f_mag = laser_blaster.f_mag
		damage = laser_blaster.damage
		ammo = ammo_time/fire_speed


	func shoot():
		var shots = []
		var shot
		for _i in range(no_shots):
			shot = bullet.instance()
			shot.f_mag = f_mag
			shot.damage = damage
			shots.append(shot) 
		ammo -= 1
		Utils.player_arsenal.update_hud()
		return shots
		
	func pickup_ammo():
		ammo += ammo_time/fire_speed



		
const weapon_type = {
	LASER_BLASER = "laser_blaster",
	MACHINE_GUN = "machine_gun",
	SHOTGUN = 'shotgun',
	TWIN_SHOT = 'twin_shot'
}

var current_weapon_type = weapon_type.LASER_BLASER
var arsenal: Dictionary = {
	"laser_blaster": LaserBlaster.new(),
	"machine_gun": MachineGunBlaster.new(),
	"shotgun": ShotgunBlaster.new(),
	"twin_shot": TwinShotBlaster.new()
}

			
func update_hud():
	emit_signal('update_hud')
	
func get_weapon():
	if !arsenal.has(current_weapon_type):
		return null
	return arsenal.get(current_weapon_type)

func set_weapon(new_weapon: String = "laser_blaster") -> void:
	current_weapon_type = new_weapon
	
func reset_arsenal():
	arsenal= {
	"laser_blaster": LaserBlaster.new(),
	"machine_gun": MachineGunBlaster.new(),
	"shotgun": ShotgunBlaster.new(),
	"twin_shot": TwinShotBlaster.new()
}

