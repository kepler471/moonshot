extends Node


class_name DifficultyController

var current_level
var max_level = 5
var chance_to_change_room_difficulty = 0.4
# Multiplier of the individually controlled scaling factors
var global_difficulty_scaling = 1
var no_baddies_scaling_factor = 1.2
# Each attribute has a scaling factor that controls how quickly it scales with level
# Each attribute also has a max and min value for the first level
var baddie_attributes_scaled = {
		"inital_hp": {"min_lvl_1": 1.0, "max_lvl_1": 1.0, "scaling_factor": 1.1},
		"speed": {"min_lvl_1": 230, "max_lvl_1": 230, "scaling_factor": 1.1},
		"damage_to_player": {"min_lvl_1": 0.02, "max_lvl_1": 0.02, "scaling_factor": 1.1},
		"shot_speed": {"min_lvl_1": 500, "max_lvl_1": 500, "scaling_factor": 1.1},
		"shot_damage": {"min_lvl_1": 0.4, "max_lvl_1": 0.4, "scaling_factor": 1.1}
	}

var other_attributes = {"item_drop": null}

var baddie_builder = load("res://procedural_map_generation/BaddieBuilder.gd")


func _init(level):
	current_level = level
	
	
# Generates a room difficulty score, from 1 - 7. Level 1 rooms should 
# mainly have a room difficulty score of 1, but some level 2 etc. End level rooms
# will have a significantly higher difficulty.
func random_room_difficulty():
	var room_difficulty = current_level
	if rand_range(0, 1) < chance_to_change_room_difficulty:
		if rand_range(0, 1) < 0.5:
			room_difficulty += 1
		else:
			room_difficulty -= 1
	if room_difficulty == 0:
		room_difficulty = 2
	return room_difficulty

# Based ona determined difficulty rating, fetch the number of baddies to include
# In a room. The max no of possible baddies should already have been determined in 
# Room.gd
func get_no_baddies_in_room(room_difficulty, room_size_x, room_size_y, max_baddies, min_baddies):
	var max_difficulty_rating = room_size_x*room_size_y
	for i in range(max_level):
		max_difficulty_rating = pow(max_difficulty_rating, global_difficulty_scaling*no_baddies_scaling_factor)

	var difficulty_rating = rand_range(0.3, 1)*room_size_x*room_size_y
	for i in range(room_difficulty):
		difficulty_rating = pow(difficulty_rating, global_difficulty_scaling*no_baddies_scaling_factor)

	var scaled_difficulty_rating = difficulty_rating / max_difficulty_rating
	var no_baddies =  round(scaled_difficulty_rating*(max_baddies-min_baddies)) + min_baddies
	return no_baddies
	
# For a specific baddie type and room difficulty, return the baddie_instance
func get_baddie_instance(baddie_scene, room_difficulty):
	
	var attributes = get_random_attributes(room_difficulty)
		# This is here for demonstrative purposes and does nothing 
	var builder: BaddieBuilder = baddie_builder.new(baddie_scene)
	var baddie_instance = builder.patch_attributes(attributes).build()
	return baddie_instance
	
# Average attributes should be at level no, but can be distributed randomly
func get_random_attributes(room_difficulty):
	# In the first step assign 'points' to attributes, the points determine
	# the level of that attribute
	var attribute_levels = {}
	var attributes = {}
	var baddie_attribute_names = baddie_attributes_scaled.keys()
	for attr in baddie_attribute_names:
		attribute_levels[attr] = 1
		
	var total_points = current_level*(len(baddie_attribute_names) - 1)
	for point in range(total_points):
		var rand_attr = baddie_attribute_names[randi() % len(baddie_attribute_names)]
		attribute_levels[rand_attr] += 1
	
	# In the second step set the attribute values randomly based on the level
	for attr in baddie_attribute_names:
		var min_attr_val = baddie_attributes_scaled[attr]['min_lvl_1']
		var max_attr_val = baddie_attributes_scaled[attr]['max_lvl_1']
		var scale_factor = baddie_attributes_scaled[attr]['scaling_factor']
		var rand_attr_value = rand_range(min_attr_val, max_attr_val)
		var scaled_attr_val = rand_attr_value
		# Keep increasing it up to the
		for i in range(room_difficulty):
			scaled_attr_val = pow(scaled_attr_val, scale_factor*global_difficulty_scaling)
		
		attributes[attr] = scaled_attr_val

		
	# For now just merge with the other options, item drops can be set up at
	# a later date
	for key in other_attributes:
		attributes[key] = other_attributes[key]
	
	return attributes
