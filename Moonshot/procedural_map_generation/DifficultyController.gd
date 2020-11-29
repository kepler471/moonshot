extends Node


class_name DifficultyController

var current_level
var max_level = 5
var chance_to_change_room_difficulty = 0.4
# Multiplier of the individually controlled scaling factors
var global_difficulty_scaling = 1

var other_attributes = {"item_drop": null}

var baddie_builder = load("res://procedural_map_generation/BaddieBuilder.gd")


func _init(level):
	current_level = level
	
	
# Generates a room difficulty score, from 1 - 7. Level 1 rooms should 
# mainly have a room difficulty score of 1, but some level 2 etc. End level rooms
# will have a significantly higher difficulty.
func random_room_difficulty(room_type):
	var room_difficulty = current_level
	if room_type == 'Boss':
		return room_difficulty + 2
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
func get_no_baddies_in_room(room_difficulty, max_baddies, min_baddies):
	var scaled_difficulty_rating = (room_difficulty -1) / (max_level - 1)
	var no_baddies =  round(scaled_difficulty_rating*(max_baddies-min_baddies)) + min_baddies
	return no_baddies
	
# For a specific baddie type and room difficulty, return the baddie_instance
func get_baddie_instance(baddie_name, room_difficulty):
	var baddie_scene = load(baddie_name)
	var builder: BaddieBuilder = baddie_builder.new(baddie_scene)
	var attributes = get_random_attributes(room_difficulty, builder, baddie_name)


	var baddie_instance = builder.patch_attributes(attributes).build()
	return baddie_instance
	
# Average attributes should be at level no, but can be distributed randomly
func get_random_attributes(room_difficulty: int, baddie_builder: BaddieBuilder, baddie_name: String):
	# In the first step assign 'points' to attributes, the points determine
	# the level of that attribute

	var baddie_attributes = get_baddie_specific_attributes(baddie_name)
	var attribute_levels = {}
	var attributes = {}
	var baddie_attribute_names = baddie_attributes.keys()
	for attr in baddie_attribute_names:
		attribute_levels[attr] = 1
		
	var total_points = room_difficulty*(len(baddie_attribute_names) - 1)
	for point in range(total_points):
		var rand_attr = baddie_attribute_names[randi() % len(baddie_attribute_names)]
		attribute_levels[rand_attr] += 1
	
	# In the second step set the attribute values randomly based on the level
	for attr in baddie_attribute_names:
		# Fetch the default for this attribute
		var default_attr = baddie_builder.get_attribute(attr)
		var min_attr_factor = baddie_attributes[attr]['min_lvl_1_factor']
		var max_attr_factor = baddie_attributes[attr]['max_lvl_1_factor']
		var scale_factor = baddie_attributes[attr]['scaling_factor']
		var rand_attr_factor = rand_range(min_attr_factor, max_attr_factor)
		# Scale based on the attribute level and scale factor
		var scaled_attr_val = rand_attr_factor*default_attr*pow(scale_factor*global_difficulty_scaling, attribute_levels[attr])
		
		attributes[attr] = scaled_attr_val

		
	# For now just merge with the other options, item drops can be set up at
	# a later date
	for key in other_attributes:
		attributes[key] = other_attributes[key]
	
	return attributes

# Fine grained control over the attributes
# Each attribute has a scaling factor that controls how quickly it scales with level
# Each attribute also has a max and min fctor for the first level
func get_baddie_specific_attributes(baddie_scene_path: String) -> Dictionary:
	var baddie_name: String = get_baddie_name(baddie_scene_path)

	match baddie_name:
		"BearBoi":
			return {
				"inital_hp": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"speed": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"damage_to_player": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1}
			}
		"BearCeilingBoi":
			return {
				"inital_hp": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"speed": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"damage_to_player": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"shot_speed": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"shot_damage": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1}
			}
		"BearDroppyBoi":
			return {
				"inital_hp": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"speed": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"damage_to_player": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
			}
		"FlyBoi":
			return {
				"inital_hp": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"speed": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"damage_to_player": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
			}
		"WallBoi":
			return {
				"inital_hp": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"speed": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"damage_to_player": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"shot_speed": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1},
				"shot_damage": {"min_lvl_1_factor": 0.8, "max_lvl_1_factor": 1.2, "scaling_factor": 1.1}
			}
		"TankyBoi":
			return {}
		_:
			return {}

func get_baddie_name(baddie_scene_path: String) -> String:
	return baddie_scene_path.replace("res://baddies/characters/", "").replace(".tscn", "")

