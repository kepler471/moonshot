extends Node


var weapon_textures = {
	'laser_blaster': load('res://items_objects/assets/WeaponIcons/LaserBlasterIcon.png'),
	'machine_gun': load('res://items_objects/assets/WeaponIcons/MachineGunIcon.png'),
	'twin_shot': load('res://items_objects/assets/WeaponIcons/TwinBlasterIcon.png'),
	'shotgun': load('res://items_objects/assets/WeaponIcons/ShotgunIcon.png')
}

	
func _process(delta):
	var new_health_bar_size = (Utils.player_stats.health*154) / Utils.player_stats.max_health
	var health_bar = get_parent().get_node("GUI/MarginContainer/VBoxContainer/VBoxContainer3/VBoxContainer2/HBoxContainer2/HealthBar")
	if new_health_bar_size > 0:
		health_bar.rect_min_size.x = new_health_bar_size
	else:
		health_bar.rect_min_size.x = 0
	update_firerate_hud(Utils.player_stats.modifiers['firerate_pickups'], Utils.player_stats.current_firerate_level)

func build_hud(minimap):
	get_parent().find_node('GUI').add_child(minimap.minimap_node)
	minimap.minimap_node.position = Vector2(900, 500)
	Utils.player_stats.connect("firerate_changed",self,"update_firerate_hud") #signal from BaseRoom.gd
	update_firerate_hud(Utils.player_stats.modifiers['firerate_pickups'], Utils.player_stats.current_firerate_level)
	Utils.player_arsenal.connect("update_hud",self,"update_gun_hud") #signal from BaseRoom.gd
	update_gun_hud()


func update_firerate_hud(new_firerate, firerate_level):
	var firerate_level_path = "/root/GUI/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/ColorRect/Level"
	for level in range(1, Utils.player_stats.max_firerate_level):
		var level_box = get_parent().find_node('Level' + str(level))
		# If the level is below the current unlocked level then set it to the
		# unlocked colour
		if level <= Utils.player_stats.unlocked_firerate_level:
			if level < firerate_level:
				# Active firerate buff colour
				level_box.color = Color8(21, 184, 39)
			else:
				# Unactive firerate buff colour
				level_box.color = Color8(27, 66, 147)
		else:
			# Locked firerate buff colour
			level_box.color = Color8(123, 3, 0)
			
	# Now scale the power par to leveling up the firerate
	var remainder_firerate_pickups = Utils.player_stats.modifiers['firerate_pickups'] % Utils.player_stats.no_firerate_pickups_to_increase_firerate
	var new_firerate_bar_size = remainder_firerate_pickups*104 / Utils.player_stats.no_firerate_pickups_to_increase_firerate
	var firerate_bar = get_parent().find_node("FirerateIncBar")
	if new_firerate_bar_size  > 0:
		firerate_bar.rect_size.y = new_firerate_bar_size
	else:
		firerate_bar.rect_size.y = 0

		
func update_gun_hud():
	var weapon = Utils.player_arsenal.get_weapon()
	var weapon_type = weapon.name
	var ammo = weapon.ammo
	var sprite_node = get_parent().find_node('GunSprite')
	var ammo_node: Label = get_parent().find_node('Ammo')
	if weapon_type == 'laser_blaster':
		sprite_node.texture = weapon_textures['laser_blaster']
	elif weapon_type == 'machine_gun':
		sprite_node.texture = weapon_textures['machine_gun']
	elif weapon_type == 'twin_shot':
		sprite_node.texture = weapon_textures['twin_shot']
	elif weapon_type == 'shotgun':
		sprite_node.texture = weapon_textures['shotgun']
	
	ammo_node.text = str(ammo)
