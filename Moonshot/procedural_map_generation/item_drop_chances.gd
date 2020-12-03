extends Node


var item_weights: Dictionary = {
'HealthPickup': 20,
'FirerateDropUnlock': 1,
'MachineGun': 10,
'Shotgun':10,
'TwinShot': 10}

var item_paths: Dictionary = {
'HealthPickup': "res://items_objects/item_pickups/HealthPickup.tscn",
'FirerateDropUnlock': "res://items_objects/item_pickups/FirerateDropUnlock.tscn",
'MachineGun': "res://items_objects/weapon_pickups/MachineGun.tscn",
'Shotgun':"res://items_objects/weapon_pickups/Shotgun.tscn",
'TwinShot': "res://items_objects/weapon_pickups/TwinShot.tscn"}


# Fetches a random item based on the relative weights above and the items to select from
func get_random_item(items):
	var items_probabilities = {}
	var item_probability_ranges = {}
	var total_weight = 0
	# Get the total weights
	for item in items:
		total_weight += item_weights[item]
	
	# Calculate the cumulative probabilities
	var total = 0
	for item in items:
		total += item_weights[item]
		items_probabilities[item] = float(total) / float(total_weight)
	
	# Calculate the probability ranges for each item 
	item_probability_ranges[items[0]] = {'min': 0, 'max': items_probabilities[items[0]]}
	for i in range(1, len(items)):
		item_probability_ranges[items[i]] = {'min': items_probabilities[items[i-1]], 'max': items_probabilities[items[i]]}
		
	# Generate a random number between 0 and 1 and use it to sample the 
	# discrete distribution
	randomize()
	var rand_float = rand_range(0, 1)
	for item in items:
		# If it is in the correct range then return an instance of the item
		if rand_float > item_probability_ranges[item]['min'] && rand_float < item_probability_ranges[item]['max']:
			var item_instance = load(item_paths[item]).instance()
			return item_instance
	
		
		
	
